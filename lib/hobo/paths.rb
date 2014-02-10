module Hobo
  class << self
    attr_accessor :project_path

    def config_path
      File.join(ENV['HOME'], '.hobo')
    end

    def seed_cache_path
      File.join(config_path, 'seeds')
    end

    def project_path
      return @project_path unless @project_path.nil?
      dir = Dir.pwd.split('/').reverse
      min_length = Gem.win_platform? ? 1 : 0

      while dir.length > min_length
        test_dir = dir.reverse.join('/')
        match = [
          File.exists?(File.join(test_dir, 'Hobofile')),
          File.exists?(File.join(test_dir, 'tools', 'hobo')),
          File.exists?(File.join(test_dir, 'tools', 'vagrant', 'Vagrantfile'))
        ] - [false]

        return @project_path = test_dir if match.length > 0

        dir.pop
      end
      return @project_path = nil
    end

    def project_bin_path
      return nil if !project_path
      File.join(project_path, 'bin')
    end

    def hobofile_path
      return nil if !project_path
      File.join(project_path, 'Hobofile')
    end

    def project_config_file
      return nil if !project_path
      File.join(project_path, 'tools', 'hobo', 'storage.yaml')
    end

    def user_config_file
      File.join(config_path, 'config.rb')
    end

    def user_hobofile_path
      File.join(config_path, 'Hobofile')
    end
  end
end