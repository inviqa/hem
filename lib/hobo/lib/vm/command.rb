module Hobo
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

        def << pipe
          pipe = "echo #{pipe.shellescape}" if opts[:auto_echo]
          @pipe = pipe
          @opts[:psuedo_tty] = false
          return self
        end

        def < pipe
          pipe = "echo '#{pipe.shellescape}'" if opts[:auto_echo]
          @pipe_in_vm = pipe
          @opts[:psuedo_tty] = false
          return self
        end

        # TODO Refactor in to ssh helper with similar opts to shell helper
        # TODO Migrate all vm_shell functionality this direction
        def run
          return if @command.nil?
          require 'net/ssh/simple'
          opts = @@vm_inspector.ssh_config.merge(@opts)

          Net::SSH::Simple.sync do
            ssh_opts = {
                :user => opts[:ssh_user],
                :port => opts[:ssh_port],
                :forward_agent => true,
                :global_known_hosts_file => "/dev/null",
                :paranoid => false,
                :user_known_hosts_file => "/dev/null"
            }

            ssh_opts[:keys] = [opts[:ssh_identity]] if opts[:ssh_identity]

            tmp = Tempfile.new "vm_command_exec"

            begin
              filename = File.basename(tmp.path)
              remote_file = "/tmp/#{filename}"
              tmp.write "#{@command}#{opts[:append]}"
              tmp.close

              scp_put opts[:ssh_host], tmp.path, remote_file, ssh_opts
              result = ssh opts[:ssh_host], "cd #{opts[:pwd]}; exec /bin/bash #{remote_file}", ssh_opts
              ssh opts[:ssh_host], "rm #{remote_file}", ssh_opts
              with_session opts[:ssh_host], opts do |session|
                session.process.popen3 do |input, output, error|

                end
              end

              # Throw exception if exit code not 0

              return opts[:capture] ? result.stdout : result.success
            ensure
              tmp.unlink
            end
          end
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
              @pipe_in_vm,
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