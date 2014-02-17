module Hobo
  class << self
    attr_accessor :asset_applicators
    def asset_applicators
      @asset_applicators ||= AssetApplicatorRegistry.new
    end
  end

  private

  class AssetApplicatorRegistry < Hash
    def register pattern, &block
      self[pattern] = block
    end
  end
end