require 'spec_helper'

describe Hobo::Helper do
  describe "locate" do
    it "should yield filename and path for matches"
    it "should match files in git"
    it "should fallback to files not in git if no matches from git"
    it "should chdir to file path before yielding"
    it "should yield once for each matching file"
  end
end
