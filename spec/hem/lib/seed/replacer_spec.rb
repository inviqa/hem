OldFile = File

describe Hem::Lib::Seed::Replacer do
  before do
    FakeFS.activate!
    def File.fnmatch?(pattern, path)
      OldFile.fnmatch?(pattern, path)
    end

    Dir.mkdir('/project')
    Dir.mkdir('/project/bin')
    Dir.mkdir('/project/dir')
    Dir.chdir('/project')

    {
      "test1.erb" => "some <%= config.test %> is here",
      "test2.erb" => "no test is here",
      "dir/test.erb" => "subdir <%= config.test %>",
      "dir/nested.erb" => "nested <%= config.nested.test %>",
      "dir/no-utf.erb" => "\xc2 <%= config.test %>", # invalid utf should be skipped
      "bin/test" => "<%= config.test %>" # non-ERB files should be ignored
    }.each do |name, content|
      File.write(name, content)
    end

    Hem.project_config = DeepStruct.wrap({})
    @replacer = Hem::Lib::Seed::Replacer.new
  end

  after do
    FakeFS::FileSystem.clear
    FakeFS.deactivate!
  end

  it "should not replace non-ERB files" do
    @replacer.replace(".", DeepStruct.wrap({ :test => 'badger' }))
    File.read("./bin/test").should eq "<%= config.test %>"
  end

  it "should replace placeholders in files" do
    @replacer.replace(".", DeepStruct.wrap({ :test => 'badger' }))

    File.read("./test1").should eq "some badger is here"
    File.read("./dir/test").should eq "subdir badger"
  end

  it "should handle nested hashes" do
    @replacer.replace(".", DeepStruct.wrap({ :nested => { :test => 'nested' } }))

    File.read("./dir/nested").should eq "nested nested"
  end
  
  it "should exclude excluded patterns" do
    @replacer.replace(".", DeepStruct.wrap({ :test => 'badger' }), ['dir/**'])

    File.read("./test1").should eq "some badger is here"
    File.read("./dir/test.erb").should eq "subdir <%= config.test %>"
    File.exist?("./dir/test").should be_false
  end
end
