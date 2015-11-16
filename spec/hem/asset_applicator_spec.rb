
describe Hem::AssetApplicatorRegistry do
  describe "asset_applicators accessor" do
    it "should initialize registry if none exists" do
      Hem.asset_applicators = nil
      Hem.asset_applicators.should be_an_instance_of Hem::AssetApplicatorRegistry
    end

    it "should return registry if exists" do
      Hem.asset_applicators.register "test" do
        "test"
      end

      Hem.asset_applicators["test"].should be_an_instance_of Proc
      Hem.asset_applicators["test"].call.should match "test"
    end
  end

  describe "register" do
    it "should store passed block with pattern" do
      registry = Hem::AssetApplicatorRegistry.new
      registry.register "abc" do
        "block"
      end

      registry["abc"].should be_an_instance_of Proc
      registry["abc"].call.should match "block"
    end
  end
end
