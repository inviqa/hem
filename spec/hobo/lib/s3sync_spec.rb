require 'spec_helper'

describe Hobo::Lib::S3Sync do
  before do
    AWS.stub!
  end

  describe "sync" do
    it "should synchronize s3 files to local"
    it "should synchronize local files to s3"
    it "should add files that only exist in source"
    it "should update files that have changed"
    it "should remove files that do not exist in source"
    it "should update progress as files are transferred"
  end
end
