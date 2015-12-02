module Hem
  module Lib
    module Local
      class Command
        attr_accessor :opts, :command

        def initialize command, opts = {}
          @command = command
          @opts = {
              :auto_echo => false,
              :pwd => opts[:pwd] || Hem.project_path,
              :append => ''
          }.merge(opts)
        end

        def pipe cmd, pipe_opts = {}
          pipe_opts = pipe_opts.merge({ :on => :host })
          cmd = "echo #{cmd.shellescape}" if @opts[:auto_echo]

          case pipe_opts[:on]
            when :host
              @pipe = cmd
            else
              raise "Unknown pipe source: #{pipe_opts[:on]}"
          end
          return self
        end

        def << cmd
          pipe cmd, :on => :host
        end

        def < cmd
          pipe cmd, :on => :host
        end

        def run
          return if @command.nil?
          shell @command, @opts
        end

        def to_s
          pwd_set_command = "cd #{@opts[:pwd].shellescape} && exec /bin/bash"

          command = [
              pwd_set_command,
              @command.empty? ? nil : @command.shellescape
          ].compact.join(" -c ") + "#{opts[:append].shellescape}"

          [
              @pipe,
              "(#{command})"
          ].compact.join(" | ")
        end

        def to_str
          to_s
        end
      end
    end
  end
end
