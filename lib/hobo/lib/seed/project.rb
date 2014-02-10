module Hobo
  module Lib
    module Seed
      class Project
        def initialize(opts = {})
          @opts = {
            :replacer => Replacer.new,
            :config_class => Hobo::Config::File,
            :project_config_file => Hobo.project_config_file
          }.merge! opts
        end

        def setup seed, config
          seed.update
          seed.export config[:project_path]
          config[:seed][:version] = seed.version

          @opts[:replacer].replace(config[:project_path], config)

          project_path = config[:project_path]
          config.delete :project_path
          @opts[:config_class].save @opts[:project_config_file], config

          initialize_git project_path, config[:git_url]
        end

        private

        def initialize_git path, git_url
          Dir.chdir path do
            Hobo::Helper.shell 'git', 'init'
            Hobo::Helper.shell 'git', 'remote', 'add', 'origin', git_url
            Hobo::Helper.shell 'git', 'add', '--all'
            Hobo::Helper.shell 'git', 'commit', '-m', "'Initial hobo project'"
            Hobo::Helper.shell 'git', 'checkout', '-b', 'develop'
          end
        end
      end
    end
  end
end