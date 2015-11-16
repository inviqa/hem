
describe Hem::Metadata do
  before do
    Hem::Metadata.store = {}
    Hem::Metadata.metadata = {}
    Hem::Metadata.defaults = {}
  end

  describe "store" do
    it "should expose storage" do
      Hem::Metadata.store[:opts] = {}
      Hem::Metadata.store[:opts].should be {}
    end
  end

  describe "metadata" do
    it "should expose metadata" do
      Hem::Metadata.store[:type] = "value"
      Hem::Metadata.add "key", :type
      Hem::Metadata.metadata["key"][:type].should match "value"
    end
  end

  describe "add" do
    it "should assign store value to task metadata for type" do
      Hem::Metadata.store[:type] = "value"
      Hem::Metadata.add "key", :type
      Hem::Metadata.metadata["key"][:type].should match "value"
    end

    it "should set store value to default after add" do
      Hem::Metadata.default :type, "value"
      Hem::Metadata.add "key", :type
      Hem::Metadata.metadata["key"][:type].should match "value"
    end
  end

  describe "default" do
    it "should store default value for type" do
      Hem::Metadata.default :type, "default"
      Hem::Metadata.add "key", :type
      Hem::Metadata.metadata["key"][:type].should match "default"
    end
  end

  describe "reset" do
    it "should reset all current store values to defaults" do
      Hem::Metadata.default :type, "default"
      Hem::Metadata.add "key", :type
      Hem::Metadata.add "key", :other_type
      Hem::Metadata.reset_store
      Hem::Metadata.store.should eq({ :type => "default" })
    end
  end
end
