
describe Hem::Config::File do
  before do
    Hem.project_path = nil
    FakeFS.activate!
  end

  after do
    FakeFS::FileSystem.clear
    FakeFS.deactivate!
  end

  def fake_config
    {
      :string => "string",
      :integer => 0,
      :boolean => true,
      :hash => { :test => true },
      :array => [ 1 ]
    }
  end

  describe "save" do
    it "should save config hash to specified file" do
      Hem::Config::File.save "test.yaml", fake_config
      File.read("test.yaml").should match /string: string/
    end

    it "should automatically unwrap deepstruct" do
      Hem::Config::File.save "test.yaml", DeepStruct.wrap(fake_config)
      File.read("test.yaml").should match /string: string/
    end
  end

  describe "load" do
    it "should wrap loaded config with DeepStruct::HashWrapper" do
      Hem::Config::File.save "test.yaml", fake_config
      Hem::Config::File.load("test.yaml").should be_an_instance_of DeepStruct::HashWrapper
    end

    it "should load config hash from file" do
      Hem::Config::File.save "test.yaml", fake_config
      fake_config().should eq Hem::Config::File.load("test.yaml").unwrap
    end

    it "should return empty config if file does not exist" do
      Hem::Config::File.load("test.yaml").unwrap.should eq({})
    end

    it "should raise error if file can't be parsed" do
      File.write("test.yaml", "##Invalid yaml file")
      expect { Hem::Config::File.load("test.yaml") }.to raise_error(RuntimeError, "Invalid hem configuration (test.yaml)")
    end
  end
end
