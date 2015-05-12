module Hem
  class Null
    def method_missing(method, *args, &block)
      self
    end

    def nil?
      true
    end

    def to_a
      []
    end

    def to_s
      ""
    end

    def to_f
      0.0
    end

    def to_i
      0
    end
  end
end

def maybe val
  val.nil? ? nil : val
end
