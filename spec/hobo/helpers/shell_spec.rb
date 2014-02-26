require 'spec_helper'

describe Hobo::Helper do
  describe "bundle_shell" do
    it "should execute command with bundle exec if bundle present"
    it "should execte command normally if no bundle present"
  end

  describe "shell" do
    it "should run the specified external command"
    it "should return captured output if :capture specified"
    it "should display output if :realtime specified"
    it "should indent output if :realtime and :indent specified"
    it "should apply block to each line if block passed"
    it "should not display lines for which the filter block returned nil"
    it "should buffer all command output in a temporary file"
    it "should throw Hobo::ExternalCommandError on non-zero exit code"
    it "should colour stderr output with red"
    it "should set ENV args for command if specified with :env"
  end
end
