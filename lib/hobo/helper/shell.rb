require 'open3'
require 'tempfile'

module Hobo
  module Helper
    def shell *args, &block
      self.shell *args, &block
    end

    def bundle_shell *args, &block
      self.bundle_shell *args, &block
    end

    def self.bundle_shell *args, &block
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

    def self.shell *args, &block
      opts = (args.size > 1 && args.last.is_a?(Hash)) ? args.pop : {}
      opts = {
        :capture => false,
        :indent => 0,
        :realtime => false,
        :env => {}
      }.merge! opts

      Hobo::Logging.logger.debug("helper.shell: Invoking '#{args.join(" ")}' with #{opts.to_s}")

      indent = " " * opts[:indent]
      ::Open3.popen3 opts[:env], *args do |stdin, out, err, external|
        buffer = ::Tempfile.new 'hobo_run_buf'
        buffer.sync = true
        threads = [external]

        ## Create a thread to read from each stream
        { :out => out, :err => err }.each do |key, stream|
          threads.push(::Thread.new do
            until (line = stream.gets).nil? do
              line = ::Hobo.ui.color(line.strip, :error) if key == :err
              buffer.write("#{line.strip}\n")
              Hobo::Logging.logger.debug("helper.shell: #{line.strip}")
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