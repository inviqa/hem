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

          Hobo.ui.success "Exporting seed to #{path}"

          tmp_path = Dir.mktmpdir("hobo-seed-export")

          Dir.chdir @seed_path do
            Hobo::Helper.shell "git clone . #{tmp_path}"
          end

          Dir.chdir tmp_path do
            Hobo.ui.success "Cloning submodules"
            Hobo::Helper.shell "git submodule update --init", :realtime => true, :indent => 2

            Hobo.ui.success "Exporting seed"
            Hobo::Helper.shell "git archive master | tar -x -C #{path.shellescape}"

            # Export submodules
            # git submodule foreach does not play nice on windows so we fake it here
            submodules = Hobo::Helper.shell "git submodule status", :capture => true
            submodules.split("\n").each do |line|
              matches = line.match /^\s*[a-z0-9]+ (.+) \(.*\)/
              next unless matches
              submodule_path = matches[1]
              Hobo.ui.success "Exporting '#{submodule_path}' seed submodule"
              Hobo::Helper.shell "cd #{tmp_path}/#{submodule_path.shellescape} && git archive HEAD | tar -x -C #{path}/#{submodule_path.shellescape}"
            end
          end

          FileUtils.rm_f tmp_path
        end

        def update
          Hobo.ui.success "Fetching / Updating seed"
          FileUtils.mkdir_p @seed_path
          if File.exists? File.join(@seed_path, 'HEAD')
            Dir.chdir @seed_path do
              logger.info "Updating seed in #{@seed_path}"
              # Need to be specific here as GH for windows adds an invalid "upstream" remote to all repos
              Hobo::Helper.shell 'git', 'fetch', 'origin'
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
            path = File.expand_path name
            if name.match(/^(\.|\/|\/~)/) && path
              path
            else
              "git@github.com:inviqa/hobo-seed-#{name}"
            end
          end
        end
      end
    end
  end
end