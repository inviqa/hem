module Hem
  module Lib
    module Vm
      class Inspector
        attr_accessor :ssh_config, :project_mount_path, :project_config

        def project_mount_path
          configured_path = maybe(Hem.project_config.vm.project_mount_path)
          return configured_path if configured_path
          return @project_mount_path if @project_mount_path

          tmp = Tempfile.new('vm_command_locator', Hem.project_path)

          begin
            tmp.write(Hem.project_path)

            locator_file = File.basename(tmp.path)

            pattern = Hem.windows? ? 'vboxsf' : Hem.project_path.shellescape

            sed = 's/.* on \(.*\) type.*/\1\/%%/g'.gsub('%%', locator_file)
            locator_results = Command.new(
                "mount | grep #{pattern} | sed -e\"#{sed}\" | xargs md5sum",
                :capture => true,
                :pwd => '/'
            ).run
          ensure
            tmp.unlink
          end

          match = locator_results.match(/^([a-z0-9]{32})\s+(.*)$/)

          raise Exception.new("Unable to locate project mount point in VM") if !match

          @vm_project_mount_path = File.dirname(match[2])

          # Stash it in config
          Hem.project_config[:vm] ||= {}
          Hem.project_config[:vm][:project_mount_path] = @vm_project_mount_path
          Hem::Config::File.save(Hem.project_config_file, Hem.project_config)

          return @vm_project_mount_path
        end

        def ssh_config
          return @ssh_config if @ssh_config
          config = nil
          locate "*Vagrantfile" do
            config = shell "vagrant ssh-config", :capture => true
          end

          raise Exception.new "Could not retrieve VM ssh configuration" unless config

          return config
        end
      end
    end
  end
end
