require 'spec_helper'

describe Hobo::Lib::Seed::Replacer do
  before do
    FakeFS.activate!
    Dir.mkdir("bin")
    Dir.mkdir("dir")
    {
      "./test1" => "some {{test}} is here",
      "./test2" => "no test is here",
      "./dir/test" => "subdir {{test}}",
      "./dir/nested" => "nested {{nested.test}}",
      "./dir/no-utf" => "\xc2 {{test}}", # invalid utf should be skipped
      "./bin/test" => "{{test}}" # bin/ should be ignored
    }.each do |name, content|
      File.write(name, content)
    end

    @replacer = Hobo::Lib::Seed::Replacer.new
  end

  after do
    FakeFS::FileSystem.clear
    FakeFS.deactivate!
  end

  it "should respect exclude directories" do
    files = @replacer.replace(".", { :test => 'badger' })
    File.read("./bin/test").should eq "{{test}}"
  end

  it "should replace placeholders in files" do
    files = @replacer.replace(".", { :test => 'badger' })
    expect(files.sort).to eq(["./dir/test", "./test1"])

    File.read("./test1").should eq "some badger is here"
    File.read("./dir/test").should eq "subdir badger"
  end

  it "should handle nested hashes" do
    files = @replacer.replace(".", { :nested => { :test => 'nested' } })
    expect(files.sort).to eq(["./dir/nested"])

    File.read("./dir/nested").should eq "nested nested"
  end
end
