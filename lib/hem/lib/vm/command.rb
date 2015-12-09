module Hem
  module Lib
    module Vm
      class Command
        class << self
          attr_accessor :vm_inspector
          @@vm_inspector = Inspector.new
        end

        attr_accessor :opts, :command

        def initialize command, opts = {}
          @command = command
          @opts = {
              :auto_echo => false,
              :psuedo_tty => false,
              :pwd => opts[:pwd] || @@vm_inspector.project_mount_path,
              :append => ''
          }.merge(opts)
        end

        def pipe cmd, pipe_opts = {}
          pipe_opts = pipe_opts.merge({ :on => :vm })
          cmd = "echo #{cmd.shellescape}" if @opts[:auto_echo]

          case pipe_opts[:on]
            when :vm
              @pipe_in_vm = cmd
            when :host
              @pipe = cmd
            else
              raise "Unknown pipe source: #{pipe_opts[:on]}"
          end
          @opts[:psuedo_tty] = false
          return self
        end

        def << cmd
          pipe cmd, :on => :host
        end

        def < cmd
          pipe cmd, :on => :vm
        end

        def run
          return if @command.nil?
          shell to_s, @opts
        end

        # TODO Speed up Vagrant SSH connections
        # May need to be disabled for windows (mm_send_fd: UsePrivilegeSeparation=yes not supported)
        # https://gist.github.com/jedi4ever/5657094

        def to_s
          opts = @@vm_inspector.ssh_config.merge(@opts)

          psuedo_tty = opts[:psuedo_tty] ? "-t" : ""

          ssh_command = [
              "ssh",
              "-o 'UserKnownHostsFile /dev/null'",
              "-o 'StrictHostKeyChecking no'",
              "-o 'ForwardAgent yes'",
              "-o 'LogLevel FATAL'",
              "-p #{opts[:ssh_port]}",
              "-i #{opts[:ssh_identity].shellescape}",
              psuedo_tty,
              "#{opts[:ssh_user].shellescape}@#{opts[:ssh_host].shellescape}"
          ].join(" ")

          pwd_set_command = " -- \"cd #{@opts[:pwd].shellescape}; exec /bin/bash"

          vm_command = [
              @pipe_in_vm.nil? ? nil : @pipe_in_vm.gsub(/(\\+)/, '\\\\\1'),
              @command
          ].compact.join(" | ")

          command = [
              ssh_command + pwd_set_command,
              vm_command.empty? ? nil : vm_command.shellescape
          ].compact.join(" -c ") + "#{opts[:append].shellescape}\""

          [
              @pipe,
              command
          ].compact.join(" | ")
        end

        def to_str
          to_s
        end
      end
    end
  end
end
