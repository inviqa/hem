module Hobo
  module Lib
    module Vm
      class Inspector
        attr_accessor :ssh_config, :project_mount_path, :project_config

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
          Hobo.project_config[:vm] ||= {}
          Hobo.project_config[:vm][:project_mount_path] = @vm_project_mount_path
          Hobo::Config::File.save(Hobo.project_config_file, Hobo.project_config)

          return @vm_project_mount_path
        end

        def ssh_config
          return @ssh_config if @ssh_config
          config = nil
          locate "*Vagrantfile" do
            config = bundle_shell "vagrant ssh-config", :capture => true
          end

          raise Exception.new "Could not retrieve VM ssh configuration" unless config

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