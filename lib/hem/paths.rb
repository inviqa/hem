module Hem
  class << self
    attr_accessor :project_path

    def config_path
      File.join(ENV['HOME'], '.hem')
    end

    def seed_cache_path
      File.join(config_path, 'seeds')
    end

    def project_path
      return @project_path unless @project_path.nil?
      return @project_path = Dir.pwd if File.exists? "Hemfile"

      dir = Dir.pwd.split('/').reverse
      min_length = Gem.win_platform? ? 1 : 0
      Hem::Logging.logger.debug("paths.project: Searching backwards from #{Dir.pwd}")

      while dir.length > min_length
        test_dir = dir.reverse.join('/')
        Hem::Logging.logger.debug("paths.project: Testing #{test_dir}")

        match = [
          File.exists?(File.join(test_dir, 'Hemfile')),
          File.exists?(File.join(test_dir, 'tools', 'hem')),
          File.exists?(File.join(test_dir, 'tools', 'vagrant', 'Vagrantfile'))
        ] - [false]

        return @project_path = test_dir if match.length > 0

        dir.shift
      end
      return @project_path = nil
    end

    def project_bin_path
      return nil if !project_path
      File.join(project_path, 'bin')
    end

    def hemfile_path
      return nil if !project_path
      File.join(project_path, 'Hemfile')
    end

    def project_config_file
      return nil if !project_path
      File.join(project_path, 'tools', 'hem', 'config.yaml')
    end

    def user_config_file
      File.join(config_path, 'config.yaml')
    end

    def user_hemfile_path
      File.join(config_path, 'Hemfile')
    end
  end
end
