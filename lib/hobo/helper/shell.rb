module Hobo
  module Helper

    def bundle_shell *args, &block
      has_bundle = begin
        shell "bundle", "exec", "ruby -v"
        true
      rescue ::Hobo::ExternalCommandError
        false
      end

      if has_bundle
        args = [ 'bundle', 'exec' ] + args
      end

      shell *args, &block
    end

    def shell *args, &block
      require 'open3'
      require 'tempfile'

      def chunk_line_iterator stream
        begin
          until (chunk = stream.readpartial(1024)).nil? do
            chunk.each_line do |outer_line|
              outer_line.each_line("\r") do |line|
                yield line
              end
            end
          end
        rescue EOFError
          # NOP
        end
      end

      opts = (args.size > 1 && args.last.is_a?(Hash)) ? args.pop : {}
      opts = {
        :capture => false,
        :indent => 0,
        :realtime => false,
        :env => {},
        :ignore_errors => false,
        :exit_status => false
      }.merge! opts

      Hobo::Logging.logger.debug("helper.shell: Invoking '#{args.join(" ")}' with #{opts.to_s}")

      ::Bundler.with_clean_env do
        indent = " " * opts[:indent]
        ::Open3.popen3 opts[:env], *args do |stdin, out, err, external|
          buffer = ::Tempfile.new 'hobo_run_buf'
          buffer.sync = true
          threads = [external]
          last_buf = ""

          ## Create a thread to read from each stream
          { :out => out, :err => err }.each do |key, stream|
            threads.push(::Thread.new do
              chunk_line_iterator stream do |line|
                line = ::Hobo.ui.color(line, :error) if key == :err
                buffer.write("#{line.strip}\n")
                Hobo::Logging.logger.debug("helper.shell: #{line.strip}")
                line = yield line if block
                print indent + line if opts[:realtime] && !line.nil?
              end
            end)
          end

          threads.each do |t|
            t.join
          end

          buffer.fsync
          buffer.rewind

          return external.value.exitstatus if opts[:exit_status]

          raise ::Hobo::ExternalCommandError.new(args.join(" "), external.value.exitstatus, buffer) if external.value.exitstatus != 0 && !opts[:ignore_errors]

          return opts[:capture] ? buffer.read.strip : nil
        end
      end
    end
  end
end

include Hobo::Helper
