require 'hobo/logging'

describe Hobo::Logging do
  before do
    Hobo.logger = nil
  end

  describe "module logger" do
    it "should return global logger instance" do
      Hobo.logger = "TEST"
      class LoggerTest
        include Hobo::Logging
      end

      LoggerTest.new.logger.should match "TEST"
    end
  end

  describe "global logger" do
    it "should initialize to STDOUT logger" do
      Hobo::Logging.logger.instance_variable_get('@logdev').dev.should be STDOUT
    end

    it "should initialize to WARN log level" do
      Hobo::Logging.logger.level.should eq Logger::WARN
    end
  end
end