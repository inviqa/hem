module Hem
  class << self
    attr_accessor :logger
  end

  module Logging
    def logger
      Hem::Logging.logger
    end

    def self.logger
      unless Hem.logger
        Hem.logger = Logger.new(STDOUT)
        Hem.logger.level = Logger::WARN
      end

      return Hem.logger
    end
  end
end
