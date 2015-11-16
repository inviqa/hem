
describe Hem::Logging do
  before do
    Hem.logger = nil
  end

  describe "module logger" do
    it "should return global logger instance" do
      Hem.logger = "TEST"
      class LoggerTest
        include Hem::Logging
      end

      LoggerTest.new.logger.should match "TEST"
    end
  end

  describe "global logger" do
    it "should initialize to STDOUT logger" do
      Hem::Logging.logger.instance_variable_get('@logdev').dev.should be STDOUT
    end

    it "should initialize to WARN log level" do
      Hem::Logging.logger.level.should eq Logger::WARN
    end
  end
end
