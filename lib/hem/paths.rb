module Hem
  class << self
    attr_accessor :project_path

    def config_path
      @config_path ||= begin
        config_paths = [ File.join(ENV['HOME'], '.hem'), File.join(ENV['HOME'], '.hobo') ]
        config_paths.each do |path|
          return path if File.exists? File.join(path, 'config.yaml')
        end

        FileUtils.mkdir_p(config_paths.first)
        config_paths.first
      end
    end

    def seed_cache_path
      File.join(config_path, 'seeds')
    end

    def detect_project_type limit_path = nil
      @project_type = 'Hem'
      @project_path = nil

      searches = [
        { type: "Hem", indicators: [ "Hemfile", "tools/hem"] },
        { type: "Hobo", indicators: [ "Hobofile", "tools/hobo"] },
        { type: "Hem", indicators: ["tools/vagrant/Vagrantfile"] }
      ]

      match = project_path_compat searches, limit_path
      if match
        @project_type = match[:type]
        @project_path = match[:path]
      end
    end

    def project_dsl_type
      detect_project_type if @project_type.nil?
      @project_type
    end

    def project_dsl_file
      "#{project_dsl_type}file"
    end

    def project_path
      detect_project_type if @project_type.nil?
      @project_path
    end

    def project_path_compat searches, limit_path = nil
      dir = Dir.pwd.split('/').reverse
      min_length = Gem.win_platform? ? 1 : 0
      Hem::Logging.logger.debug("paths.project: Searching backwards from #{Dir.pwd}")

      while dir.length > min_length
        test_dir = dir.reverse.join('/')
        return nil unless limit_path.nil? || test_dir.start_with?(limit_path)

        Hem::Logging.logger.debug("paths.project: Testing #{test_dir}")

        searches.each do |search|
          results = search[:indicators].map do |s|
            File.exists?(File.join(test_dir, s))
          end

          match = results - [false]

          return {type: search[:type], path: test_dir} if match.length > 0
        end

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
