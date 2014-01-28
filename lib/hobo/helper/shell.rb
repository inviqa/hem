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
      opts = (args.size > 1 && args.last.is_a?(Hash)) ? args.pop : {}
      opts = {
        :capture => false,
        :indent => 0,
        :realtime => false
      }.merge! opts

      indent = " " * opts[:indent]
      ::Open3.popen3 *args do |stdin, out, err, external|
        buffer = ::Tempfile.new 'hobo_run_buf'
        buffer.sync = true
        threads = [external]

        ## Create a thread to read from each stream
        { :out => out, :err => err }.each do |key, stream|
          threads.push(::Thread.new do
            until (line = stream.gets).nil? do
              line = ::Hobo.ui.color(line, :error) if key == :err
              buffer.write(line)
              line = yield line if block
              puts indent + line if opts[:realtime] && !line.nil?
            end
          end)
        end

        threads.each do |t|
          t.join
        end

        buffer.fsync
        buffer.rewind

        raise ::Hobo::ExternalCommandError.new(args.join(" "), external.value.exitstatus, buffer) if external.value.exitstatus != 0

        return opts[:capture] ? buffer.read.strip : nil
      end
    end
  end
end

include Hobo::Helper