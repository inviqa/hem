require 'hobo/metadata'

describe Hobo::Metadata do
  before do
    Hobo::Metadata.store = {}
    Hobo::Metadata.metadata = {}
    Hobo::Metadata.defaults = {}
  end

  describe "store" do
    it "should expose storage" do
      Hobo::Metadata.store[:opts] = {}
      Hobo::Metadata.store[:opts].should be {}
    end
  end

  describe "metadata" do
    it "should expose metadata" do
      Hobo::Metadata.store[:type] = "value"
      Hobo::Metadata.add "key", :type
      Hobo::Metadata.metadata["key"][:type].should match "value"
    end
  end

  describe "add" do
    it "should assign store value to task metadata for type" do
      Hobo::Metadata.store[:type] = "value"
      Hobo::Metadata.add "key", :type
      Hobo::Metadata.metadata["key"][:type].should match "value"
    end

    it "should set store value to default after add" do
      Hobo::Metadata.default :type, "value"
      Hobo::Metadata.add "key", :type
      Hobo::Metadata.metadata["key"][:type].should match "value"
    end
  end

  describe "default" do
    it "should store default value for type" do
      Hobo::Metadata.default :type, "default"
      Hobo::Metadata.add "key", :type
      Hobo::Metadata.metadata["key"][:type].should match "default"
    end
  end
end