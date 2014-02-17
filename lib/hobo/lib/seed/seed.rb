require 'tempfile'

module Hobo
  module Lib
    module Seed
      class Seed
        include Hobo::Logging

        def initialize(seed_path, url)
          @seed_path = seed_path
          @url = url
        end

        def export path
          path = File.expand_path(path)
          FileUtils.mkdir_p path

          logger.info "Exporting seed to #{path}"

          tmp_path = Dir.mktmpdir("hobo-seed-export")

          Dir.chdir @seed_path do
            Hobo::Helper.shell "git clone . #{tmp_path.shellescape}"
          end

          Dir.chdir tmp_path do
            Hobo::Helper.shell "git submodule update --init"
            Hobo::Helper.shell "git archive master | tar -x -C #{path.shellescape}"
            Hobo::Helper.shell "git submodule foreach 'cd #{tmp_path.shellescape}/$path && git archive HEAD | tar -x -C #{path.shellescape}/$path'"
          end

          FileUtils.rm_f tmp_path
        end

        def update
          FileUtils.mkdir_p @seed_path
          if File.exists? File.join(@seed_path, 'HEAD')
            Dir.chdir @seed_path do
              logger.info "Updating seed in #{@seed_path}"
              Hobo::Helper.shell 'git', 'fetch', '--all'
            end
          else
            logger.info "Cloning seed from #{@url} to #{@seed_path}"
            Hobo::Helper.shell 'git', 'clone', @url, @seed_path, '--mirror'
          end
        end

        def vm_ip
          [
            10,
            [*0..255].sample,
            [*0..255].sample,
            [*2..255].sample
          ].join('.')
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