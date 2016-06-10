module Hem
  VERSION = '1.1.1'

  class << self
    def require_version *requirements
      req = Gem::Requirement.new(*requirements)
      if req.satisfied_by?(Gem::Version.new(VERSION))
        return
      end

      raise HemVersionError.new(requirements)
    end
  end
end
