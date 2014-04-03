module Hobo
  class << self

    attr_accessor :project_bar_cache

    def relaunch! env = {}
      Kernel.exec(env, 'hobo', '--skip-host-checks', *$HOBO_ARGV)
    end

    def in_project?
      !!Hobo.project_path
    end

    def progress file, increment, total, type, opts = {}
      require 'ruby-progressbar'

      opts = {
        :title => File.basename(file),
        :total => total,
        :format => "%t [%B] %p%% %e"
      }.merge(opts)

      # Hack to stop newline spam on windows
      opts[:length] = 79 if Gem::win_platform?

      @progress_bar_cache ||= {}

      if type == :reset
        type = :update
        @progress_bar_cache.delete file
      end

      @progress_bar_cache[file] ||= ProgressBar.create(opts)

      case type
        when :update
          @progress_bar_cache[file].progress += increment
        when :finished
          @progress_bar_cache[file].finish
      end

      return @progress_bar_cache[file]
    end

    def aws_credentials
      {
        :access_key_id => maybe(Hobo.user_config.aws.access_key_id) || ENV['AWS_ACCESS_KEY_ID'],
        :secret_access_key => maybe(Hobo.user_config.aws.secret_access_key) || ENV['AWS_SECRET_ACCESS_KEY']
      }
    end

    def windows?
      require 'rbconfig'
      !!(RbConfig::CONFIG['host_os'] =~ /mswin|msys|mingw|cygwin|bccwin|wince|emc/)
    end
  end
end
