module Hobo
  module Lib
    module Seed
      class Seed
        def initialize(seed_path, url)
          @seed_path = seed_path
          @url = url
        end

        def export path
          path = File.expand_path(path)
          FileUtils.mkdir_p path
          Dir.chdir @seed_path do
            Hobo::Helper.shell "git archive master | tar -x -C #{path.shellescape}"
          end
        end

        def update
          FileUtils.mkdir_p @seed_path
          if File.exists? File.join(@seed_path, 'HEAD')
            Dir.chdir @seed_path do
              Hobo::Helper.shell 'git', 'fetch', '--all'
            end
          else
            Hobo::Helper.shell 'git', 'clone', @url, @seed_path, '--mirror'
          end
        end

        def version
          Dir.chdir @seed_path do
            Hobo::Helper.shell 'git', 'rev-parse', '--short', 'HEAD', :capture => true
          end
        end

        class << self
          def name_to_url name
            name.match(/\./) ? name : "git@github.com:inviqa/hobo-seed-#{name}"
          end
        end
      end
    end
  end
end