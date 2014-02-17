require 'logger'

module Hobo
  class << self
    attr_accessor :logger
  end

  module Logging
    def logger
      Hobo::Logging.logger
    end

    def self.logger
      unless Hobo.logger
        Hobo.logger = Logger.new(STDOUT)
        Hobo.logger.level = Logger::WARN
      end

      return Hobo.logger
    end
  end
end