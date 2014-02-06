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
      dir = Dir.pwd
      while File.split(dir)[1] != File.split(dir)[0]
        match = [
          File.exists?(File.join(dir, 'Hobofile')),
          File.exists?(File.join(dir, 'tools', 'hobo')),
          File.exists?(File.join(dir, 'tools', 'vagrant', 'Vagrantfile'))
        ] - [false]

        return @project_path = dir if match.length > 0

        dir = File.split(dir)[0]
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