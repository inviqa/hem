module Hem
  class << self
    attr_accessor :asset_applicators

    # Utility method to access (with initialization) the asset applicator registry.
    # This allows you to register new asset applicator methods on a per-project basis.
    # For example:
    #
    #     Hem.asset_applicators.register /.*\.zip/ do |file|
    #       Dir.chdir File.dirname(file) do
    #         shell "unzip", file
    #       end
    #     end
    #
    # @see Hem::AssetApplicatorRegistry
    # @return [Hem::AssetApplicatorRegistry] Applicator registry cotnainer
    def asset_applicators
      @asset_applicators ||= AssetApplicatorRegistry.new
    end
  end

  private

  # Thin wrapper over a hash to provide a means to "register" asset applicators
  class AssetApplicatorRegistry < Array
    # Register a new asset applicator
    # @param [String] The name of the applicator
    # @param [Regexp] Pattern to match against asset filename.
    # @yield The block to be executed when an asset matches the pattern.
    def register name, pattern, &block
      self << AssetApplicator.new(name, pattern, block)
    end
  end

  class AssetApplicator
    attr_reader :name

    def initialize(name, pattern, block)
      @name = name
      @pattern = pattern
      @block = block
    end

    def matches?(file)
      @pattern.match(file)
    end

    def call(file, opts = {})
      @block.call file, opts
    end
  end
end
