module Hobo
  module Isolation

    module Ui
  	  def self.confirm action
        interactive = (STDIN.tty? and !ARGV.include? '--non-interactive')
        puts "Hobo needs to #{action}"
        print 'Do you wish to proceed? (Y/N) [Y] ' if interactive
        answer = 'Y' unless interactive
        answer ||= STDIN.gets
        answer = answer.upcase.strip if answer
        answer == 'Y'
      end
    end

    module Gemlock
      def self.load
        require 'json'
        gemlock_file = File.expand_path('../../../Gemlock', __FILE__)
        JSON.parse(File.read(gemlock_file)) if File.exist? gemlock_file
      end

      def self.load_deps deps
        deps.each do |name, version|
          gem name, version
        end
      end

      def self.install_deps deps
        missing = {}
        deps.each do |name, version|
          dep = Gem::Dependency.new(name, [version])
          missing[name] = version if dep.matching_specs.empty?
        end

        if missing.length > 0
          exit 1 unless ::Hobo::Isolation::Ui.confirm "install some additional components"
        end

        missing.each do |name, version|
          system("gem install #{name} --ignore-dependencies --no-rdoc --no-ri -v '#{version}'", :out => STDOUT, :err => STDERR)
        end

        return missing.length
      end
    end

    module GemUtil
      def self.gem_path name, version = nil
        begin
          Gem::Specification.find_by_name(name, version).full_gem_path
        rescue Gem::LoadError
          nil
        end
      end
    end

    module BundleUtil
      def self.install_missing_dependencies
        require 'bundler'
        require 'bundler/cli'
        require 'bundler/cli/install'

        # Reset bundler & trigger install task
        ::Bundler.definition true
        bundler_install = ::Bundler::CLI::Install.new({})
        bundler_install.run
      end

      def self.get_bundle_version
        require 'bundler'
        version = nil
        begin   
          ::Bundler.root   
          ::Bundler.definition.dependencies.each do |dep|    
            if dep.name == 'hobo-inviqa'
              version = dep.requirement
              break
            end
          end  
        rescue ::Bundler::GemfileNotFound        
        end
        version
      end
    end

    def self.relaunch_isolated! path, extra_env = {}
      env = extra_env.merge({
        'HOBO_ISOLATED' => '1',
        'PATH' => [
          File.expand_path("~/.gem/ruby/#{RbConfig::CONFIG['ruby_version']}/bin"),
          File.expand_path("../../bin", path),
          ENV['PATH']
        ].join(File::PATH_SEPARATOR)
      })
      exec(env, "#{path}/bin/hobo", *ARGV)
    end

    def self.isolate
      unless ENV['HOBO_ISOLATED']
        bundled_version = ::Hobo::Isolation::BundleUtil.get_bundle_version

        if bundled_version
          _, null_io = IO.pipe
          if system("bundle check", :out => null_io, :err => null_io)
            relaunch_isolated! ::Hobo::Isolation::GemUtil.gem_path("hobo-inviqa", bundled_version)
          else
            exit 1 unless ::Hobo::Isolation::Ui.confirm "install bundle dependencies because hobo was detected in the Gemfile"

            begin
              ::Hobo::Isolation::BundleUtil.install_missing_dependencies
            rescue Exception => e
              puts e
              puts
              puts "Hobo could not install the required dependencies"
              puts "Please review the output above to resolve manually"
              puts
              puts "Aborting.."
              exit 1
            end

            relaunch_isolated! ::Hobo::Isolation::GemUtil.gem_path("hobo-inviqa", bundled_version)
          end
        end

        isolated_path = File.expand_path("~/.hobo/gems/#{RbConfig::CONFIG['ruby_version']}")

        relaunch_isolated!(
          File.expand_path('../../../', __FILE__),
          'GEM_PATH' => isolated_path,
          'GEM_HOME' => isolated_path
        )

      else
        gems = ::Hobo::Isolation::Gemlock.load
        if gems
          installed = ::Hobo::Isolation::Gemlock.install_deps gems
          relaunch_isolated! File.expand_path('../../../', __FILE__) if installed > 0
          ::Hobo::Isolation::Gemlock.load_deps gems
        end
      end
    end
  end
end