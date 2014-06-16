module Hobo
  module Bundler
    require 'rubygems/user_interaction'
    
    class GemUi < Gem::SilentUI
      def download_reporter(*args)
        VerboseDownloadReporter.new(STDOUT, *args)
      end
      def progress_reporter(*args)
        SilentProgressReporter.new(STDOUT, *args)
      end
    end

    def self.install_missing_dependencies
      require 'bundler'
      require 'bundler/ui'
      require 'bundler/cli'
      require 'bundler/cli/install'

      # Override Gem output handlers
      Gem::DefaultUserInteraction.ui = GemUi.new
      Gem.configuration.verbose = false

      # Reset bundler & trigger install task
      ::Bundler.definition true
      bundler_install = ::Bundler::CLI::Install.new({})

      begin
        bundler_install.run
        Kernel.exec('hobo', *$HOBO_ARGV)
      rescue Exception => e
        puts
        puts "Failed to install dependencies. Hobo can not proceed."
        puts "Please see the error below:"
        puts
        throw exception
      end
    end

    def self.isolate
      ::Bundler.with_clean_env do
        # Override gemfile for bundler to use
        ENV['BUNDLE_GEMFILE'] = File.expand_path('../../../Gemfile', __FILE__)

        # Ensure Bundler is not caching anything
        ::Bundler.instance_variable_set('@load', nil)
        ::Bundler.definition true

        begin
          ::Bundler.setup(:default)
        rescue ::Bundler::GemNotFound => exception
          puts "Missing runtime dependencies: #{exception}"
          puts "Installing..."

          Hobo::Bundler.install_missing_dependencies
        end
        yield
      end
    end

    def self.is_hobo_bundled?
      begin
        ::Bundler.root
        ::Bundler.definition.dependencies.select do |dep|
          dep.name == 'hobo-inviqa'
        end.length > 0
      rescue ::Bundler::GemfileNotFound
        false
      end
    end
  end
end
