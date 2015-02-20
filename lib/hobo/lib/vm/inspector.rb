module Hobo
  module Lib
    module Vm
      class Inspector
        attr_accessor :ssh_config, :project_mount_path, :project_config, :path

        class << self
          attr_accessor :instances

          def instances
            @instances = (@instances || {})
          end

          def register handle, instance
            instances[handle] = instance
          end

          def instance handle
            handle = handle.downcase.to_sym
            register(handle, Inspector.new) if handle == :default and !instances[handle]
            instances[handle]
          end
        end

        def initialize opts = {}
          @path = opts[:path] if opts[:path]
          @project_mount_path = opts[:project_mount_path] if opts[:project_mount_path]
          self.class.register(opts[:register_as], self) if opts[:register_as]
          @ssh_config = opts[:ssh_config] || ssh_config(opts[:ssh_config_file])
        end

        def started?
          require 'net/ssh/simple'
          begin
            result = vm_shell "/bin/true", :exit_status => true, :inspector => self
            return result == 0
          rescue Net::SSH::Simple::Error => e
            puts e
            # NOP - not started
          rescue Hobo::VmNotStartedError => e
            puts e
            # NOP - not started
          end

          return false
        end

        def project_mount_path
          configured_path = maybe(Hobo.project_config.vm.project_mount_path)
          return configured_path if configured_path
          return @project_mount_path if @project_mount_path

          tmp = Tempfile.new('vm_command_locator', Hobo.project_path)

          begin
            tmp.write(Hobo.project_path)

            locator_file = File.basename(tmp.path)

            pattern = Hobo.windows? ? 'vboxsf' : Hobo.project_path.shellescape

            sed = 's/.* on \(.*\) type.*/\1\/%%/g'.gsub('%%', locator_file)
            locator_results = vm_shell(
                "mount | grep #{pattern} | sed -e\"#{sed}\" | xargs md5sum",
                :capture => true,
                :pwd => '/',
                :inspector => self
            )
          ensure
            tmp.unlink
          end

          match = locator_results.match(/^([a-z0-9]{32})\s+(.*)$/)

          raise Exception.new("Unable to locate project mount point in VM") if !match

          @vm_project_mount_path = File.dirname(match[2])

          # Stash it in config
          Hobo.project_config[:vm] ||= {}
          Hobo.project_config[:vm][:project_mount_path] = @vm_project_mount_path
          Hobo::Config::File.save(Hobo.project_config_file, Hobo.project_config)

          return @vm_project_mount_path
        end

        def ssh_config file = nil
          return @ssh_config if @ssh_config

          config = if file and File.exist? file
            File.read(file)
          end

          if config.nil?
            locate "*Vagrantfile", :path => @path do
              begin
                config = shell "vagrant ssh-config", :capture => true
              rescue Hobo::ExternalCommandError => e
                raise Hobo::VmNotStartedError.new
              end
            end
          end

          patterns = {
              :ssh_user => /^\s*User (.*)$/,
              :ssh_identity => /^\s*IdentityFile (.*)$/,
              :ssh_host => /^\s*HostName (.*)$/,
              :ssh_port => /^\s*Port (\d+)/
          }

          output = {}

          patterns.each do |k, pattern|
            match = config.match(pattern)
            output[k] = match[1] if match
          end

          return @ssh_config = output
        end
      end
    end
  end
end
