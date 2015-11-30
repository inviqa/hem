module Hem
  class << self
    attr_accessor :project_path

    def config_path
      [ File.join(ENV['HOME'], '.hem'), File.join(ENV['HOME'], '.hobo') ].each do |path|
        return path if File.exists? File.join(path, 'config.yaml')
      end
    end

    def seed_cache_path
      File.join(config_path, 'seeds')
    end

    def detect_project_type
      return unless @project_type.nil?

      searches = [
        { type: "Hem", indicators: [ "Hemfile", "tools/hem"] },
        { type: "Hobo", indicators: [ "Hobofile", "tools/hobo"] },
        { type: "Hem", indicators: ["tools/vagrant/Vagrantfile"] }
      ]

      searches.each do |search|
        next if @project_path
        path = project_path_compat search
        if path
          @project_type = search[:type]
          @project_path = path
          break
        end
      end

      @project_type ||= 'Hem'
    end

    def project_dsl_type
      detect_project_type
      @project_type
    end

    def project_dsl_file
      "#{project_dsl_type}file"
    end

    def project_path
      detect_project_type
      @project_path
    end

    def project_path_compat search
      dir = Dir.pwd.split('/').reverse
      min_length = Gem.win_platform? ? 1 : 0
      Hem::Logging.logger.debug("paths.project: Searching backwards from #{Dir.pwd}")

      while dir.length > min_length
        test_dir = dir.reverse.join('/')
        Hem::Logging.logger.debug("paths.project: Testing #{test_dir}")

        results = search[:indicators].map do |s|
          File.exists?(File.join(test_dir, s))
        end

        match = results - [false]

        return test_dir if match.length > 0

        dir.shift
      end
      return nil
    end

    def project_bin_path
      return nil if !project_path
      File.join(project_path, 'bin')
    end

    def hemfile_path
      return nil if !project_path
      File.join(project_path, project_dsl_file)
    end

    def project_config_file
      return nil if !project_path
      File.join(project_path, 'tools', project_dsl_type.downcase, 'config.yaml')
    end

    def user_config_file
      File.join(config_path, 'config.yaml')
    end

    def user_hemfile_path
      File.join(config_path, project_dsl_file)
    end
  end
end
