module Hobo
  module Bundler
    class HoboGemUi < Gem::SilentUI
      def download_reporter(*args)
        VerboseDownloadReporter.new(STDOUT, *args)
      end
      def progress_reporter(*args)
        VerboseProgressReporter.new(STDOUT, *args)
      end
    end

    def self.install_missing_dependencies
      require 'bundler'
      require 'bundler/ui'
      require 'bundler/cli'
      require 'bundler/cli/install'

      # Override Gem output handlers
      Gem::DefaultUserInteraction.ui = HoboGemUi.new
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
