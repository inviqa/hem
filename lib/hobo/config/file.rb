require 'yaml'
require 'deepstruct'

module Hobo
  module Config
    class File
      def self.save(file, config)
        config = config.unwrap if config.public_methods.include? :unwrap
        dir = ::File.dirname file
        FileUtils.mkdir_p dir unless ::File.exists? dir
        ::File.open(file, 'w+') do |f|
          f.puts config.to_yaml
        end
      end

      def self.load(file)
        config = ::File.exists?(file) ? YAML.load_file(file) : {}
        raise "Invalid hobo configuration (#{file})" unless config
        return DeepStruct.wrap(config)
      end
    end
  end
end