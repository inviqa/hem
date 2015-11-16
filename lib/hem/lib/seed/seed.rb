module Hem
  module Lib
    module Seed
      class Seed
        include Hem::Logging

        def initialize(seed_path, url)
          @seed_path = seed_path
          @url = url
        end

        def tags
          tags = []
          Dir.chdir @seed_path do
            tag_output = Hem::Helper.shell "git tag", :capture => true
            tags = tag_output.split("\n")
          end
          tags
        end

        def export path, opts = {}
          opts = {
            :name => 'seed',
            :ref => 'master'
          }.merge(opts)

          path = File.expand_path(path)
          FileUtils.mkdir_p path

          Hem.ui.success "Exporting #{opts[:name]} to #{path}"

          tmp_path = Dir.mktmpdir("hem-seed-export")

          Dir.chdir @seed_path do
            Hem::Helper.shell "git clone --branch #{opts[:ref].shellescape} . #{tmp_path}"
          end

          Dir.chdir tmp_path do
            Hem::Helper.shell "git archive #{opts[:ref].shellescape} | tar -x -C #{path.shellescape}"

            submodules = Hem::Helper.shell "git submodule status", :capture => true, :strip => false

            next if submodules.empty?

            Hem.ui.success "Cloning submodules"
            Hem::Helper.shell "git submodule update --init", :realtime => true, :indent => 2

            # Export submodules
            # git submodule foreach does not play nice on windows so we fake it here
            submodules.split("\n").each do |line|
              matches = line.match /^[\s-][a-z0-9]+ (.+)/
              next unless matches
              submodule_path = matches[1]
              Hem.ui.success "Exporting '#{submodule_path}' #{opts[:name]} submodule"
              Hem::Helper.shell "cd #{tmp_path}/#{submodule_path.shellescape} && git archive HEAD | tar -x -C #{path}/#{submodule_path.shellescape}"
            end
          end

          FileUtils.rm_f tmp_path
        end

        def update
          Hem.ui.success "Fetching / Updating seed"
          FileUtils.mkdir_p @seed_path
          if File.exists? File.join(@seed_path, 'HEAD')
            Dir.chdir @seed_path do
              logger.info "Updating seed in #{@seed_path}"
              # Need to be specific here as GH for windows adds an invalid "upstream" remote to all repos
              Hem::Helper.shell 'git', 'fetch', 'origin'
            end
          else
            logger.info "Cloning seed from #{@url} to #{@seed_path}"
            Hem::Helper.shell 'git', 'clone', @url, @seed_path, '--mirror'
          end
        end

        def vm_ip
          [
            10,
            10,
            [*0..255].sample,
            [*2..255].sample
          ].join('.')
        end

        def version
          Dir.chdir @seed_path do
            Hem::Helper.shell 'git', 'rev-parse', '--short', 'HEAD', :capture => true
          end
        end

        class << self
          def name_to_url name, options = {}
            options = {
              :use_short_seed_name => true
            }.merge(options)

            path = File.expand_path name
            if name.include?(':')
              name
            elsif !options[:use_short_seed_name] || (name.match(/^(\.|\/|~)/) && path)
              path
            else
              "git@github.com:inviqa/hem-seed-#{name}"
            end
          end
        end
      end
    end
  end
end
