module Hobo
  module Lib
    module Vm
      class Command
        include Hobo::Logging

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
              :append => '',
              :indent => 0
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

        def upload_command_file command, opts = {}
          require 'net/ssh'
          require 'net/ssh/simple'
          Net::SSH::Simple.sync do
            ssh_opts = {
                :user => opts[:ssh_user],
                :port => opts[:ssh_port],
                :forward_agent => true,
                :global_known_hosts_file => "/dev/null",
                :paranoid => false,
                :user_known_hosts_file => "/dev/null",
                :timeout => 3600
            }

            ssh_opts[:keys] = [opts[:ssh_identity]] if opts[:ssh_identity]

            tmp = Tempfile.new "vm_command_exec"
            filename = File.basename(tmp.path)

            begin
              # TODO make this trapped
              remote_file = "/tmp/#{filename}"
              tmp.write "#!/bin/bash\n"
              tmp.write "set -e\n"
              tmp.write "cd #{opts[:pwd]}\n" if opts[:pwd]
              tmp.write "#{command}#{opts[:append]}\n"
              tmp.write "R=$?\n"
              tmp.write "rm #{remote_file}\n"
              tmp.write "exit $R"

              tmp.rewind
              logger.debug "vmcommand: Uploading `#{command}#{opts[:append]}` as '#{remote_file}'"

              tmp.close

              scp_put opts[:ssh_host], tmp.path, remote_file, ssh_opts
              # TODO error check
            ensure
              tmp.unlink
            end

            return remote_file
          end
        end

        def inner_command
          [
              @pipe_in_vm,
              @command
          ].compact.join(" | ")
        end

        def to_s
          inspector = @opts[:inspector] || @@vm_inspector
          opts = inspector.ssh_config(@opts[:ssh_config_file]).merge(@opts)

          psuedo_tty = opts[:psuedo_tty] ? "-t" : ""

          command = [
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

          vm_command = inner_command
          command = "#{command} -- bash " + upload_command_file(vm_command, opts) unless vm_command.empty?

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
