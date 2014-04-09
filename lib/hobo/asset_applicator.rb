module Hobo
  class << self
    attr_accessor :asset_applicators

    # Utility method to access (with initialization) the asset applicator registry.
    # This allows you to register new asset applicator methods on a per-project basis.
    # For example:
    #
    #     Hobo.asset_applicators.register /.*\.zip/ do |file|
    #       Dir.chdir File.dirname(file) do
    #         shell "unzip", file
    #       end
    #     end
    #
    # @see Hobo::AssetApplicatorRegistry
    # @return [Hobo::AssetApplicatorRegistry] Applicator registry cotnainer
    def asset_applicators
      @asset_applicators ||= AssetApplicatorRegistry.new
    end
  end

  private

  # Thin wrapper over a hash to provide a means to "register" asset applicators
  class AssetApplicatorRegistry < Hash
    # Register a new asset applicator
    # @param [Regexp] Pattern to match against asset filename.
    # @yield The block to be executed when an asset matches the pattern.
    def register pattern, &block
      self[pattern] = block
    end
  end
end
