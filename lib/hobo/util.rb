require 'ruby-progressbar'

module Hobo
  class << self

    attr_accessor :project_bar_cache

    def in_project?
      !!Hobo.project_path
    end

    def progress file, increment, total, type, opts = {}
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
  end
end
