module Hem
  module Lib
    module Seed
      class Project
        def initialize(opts = {})
          @opts = {
            :replacer => Replacer.new,
            :config_class => Hem::Config::File,
            :template_excludes => [],
          }.merge! opts
          @replace_done = false
        end

        def setup seed, config
          config = DeepStruct.wrap(config)
          project_path = config.project_path

          seed.update
          seed.export project_path, config

          Dir.chdir(project_path) do
            config.seed.version = seed.version
            config.hostname = "#{config.name}.dev"
            config.asset_bucket = "inviqa-assets-#{config.name}"
            config.vm = {
              :project_mount_path => "/vagrant"
            }
            config.tmp = {}

            Hem.project_path = project_path
            load_seed_init(config)

            @opts[:replacer].replace(project_path, config)

            config.delete :project_path
            config.delete :tmp

            Hem.detect_project_type project_path
            @opts[:project_config_file] = Hem.project_config_file
            @opts[:config_class].save @opts[:project_config_file], config
          end

          initialize_git project_path, config[:git_url]
        end

        private

        def config
          Hem.project_config
        end

        def option key, value
          @opts[key] = value
        end

        def load_seed_init config
          Hem.project_config = config
          seed_init_file = File.join(config.project_path, 'seedinit.rb')
          if File.exists?(seed_init_file)
            instance_eval File.read(seed_init_file), seed_init_file
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
