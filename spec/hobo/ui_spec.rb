require 'highline'
require 'hobo/ui'

describe Hobo::Ui do
  before do
    HighLine.use_color = false
  end

  describe "initialization" do
    it "should provide default color scheme"
  end

  describe "ask" do
    it "should return default if in non-interactive mode"
    it "should raise error if no default provided in non-interactive mode"
    it "should format prompt to include default if provided"
    it "should use default answer if given answer is empty"
    it "should handle stdin EOF (Ctrl+d)"
  end

  describe "color" do
    it "should format message with ansi style"
  end

  describe "use_color" do
    it "should set the use of color"
  end

  describe "color_scheme" do
    it "should set the global color scheme if argument provided"
    it "should return the global color scheme"
  end

  describe "debug" do
    it "should send message to stdout" do
      $stdout.should receive(:puts).with("test")
      Hobo::Ui.new.debug("test")
    end
  end

  describe "info" do
    it "should send message to stdout" do
      $stdout.should receive(:puts).with("test")
      Hobo::Ui.new.info("test")
    end
  end

  describe "warning" do
    it "should send message to stderr" do
      $stderr.should receive(:puts).with("test")
      Hobo::Ui.new.warning("test")
    end
  end

  describe "error" do
    it "should send message to stderr" do
      $stderr.should receive(:puts).with("test")
      Hobo::Ui.new.error("test")
    end
  end

  describe "success" do
    it "should send message to stdout" do
      $stdout.should receive(:puts).with("test")
      Hobo::Ui.new.success("test")
    end
  end
end