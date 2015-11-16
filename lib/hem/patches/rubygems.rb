# No sensible way to silence gem warnings
class Gem::Specification
  def self.warn m
    #NOP
  end
end
