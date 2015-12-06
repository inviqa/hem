module Hem
  module Lib
    module Seed
      class Project
        def initialize(opts = {})
          @opts = {
            :replacer => Replacer.new,
            :config_class => Hem::Config::File,
            :ssl_cert_generator => Hem::Lib::SelfSignedCertGenerator
          }.merge! opts
        end

        def setup seed, config
          project_path = config[:project_path]

          seed.update
          seed.export project_path, config

          Dir.chdir(project_path) do
            Hem.detect_project_type project_path
            @opts[:project_config_file] = Hem.project_config_file

            config[:seed][:version] = seed.version
            config[:hostname] = "#{config[:name]}.dev"
            config[:asset_bucket] = "inviqa-assets-#{config[:name]}"
            config[:vm] = {
              :project_mount_path => "/vagrant"
            }
            config[:ssl] = @opts[:ssl_cert_generator].generate config[:hostname]
            config[:chef_ssl] = {}
            config[:ssl].each do |k, v|
              config[:chef_ssl][k] = v.gsub("\n", "\\n")
            end

            @opts[:replacer].replace(config[:project_path], config)
            load_seed_init(config)

            config.delete :project_path
            config.delete :ssl
            config.delete :chef_ssl
            @opts[:config_class].save @opts[:project_config_file], config
          end

          initialize_git project_path, config[:git_url]
        end

        private

        def load_seed_init config
          Hem.project_config = DeepStruct.wrap(config)
          seed_init_file = File.join(config[:project_path], 'seedinit.rb')
          if File.exists?(seed_init_file)
            require seed_init_file
            File.unlink(seed_init_file)
          end
        end

        def initialize_git path, git_url
          Dir.chdir path do
            Hem::Helper.shell 'git', 'init'
            Hem::Helper.shell 'git', 'add', '--all'
            Hem::Helper.shell 'git', 'commit', '-m', "'Initial hem project'"
            Hem::Helper.shell 'git', 'checkout', '-b', 'develop'

            # Github for windows gets clever adding origin / upstream remotes in system level gitconfig
            # :facepalm:
            begin
              Hem::Helper.shell 'git', 'remote', 'add', 'origin', git_url
            rescue Hem::ExternalCommandError
              Hem::Helper.shell 'git', 'remote', 'set-url', 'origin', git_url
            end
          end
        end
      end
    end
  end
end
