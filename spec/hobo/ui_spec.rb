require 'spec_helper'

describe Hobo::Ui do
  def test_ui opts = {}
    opts = {
      :answer => "",
      :output => StringIO.new,
      :error => StringIO.new,
      :eof => false
    }.merge(opts)

    input = StringIO.new
    input << opts[:answer]
    input.rewind unless opts[:eof]
    Hobo.ui = ui = Hobo::Ui.new(input, opts[:output], opts[:error])
    ui.interactive = true
    return ui
  end

  before do
    HighLine.use_color = false
    Hobo.logger = Logger.new(nil)
    Hobo.logger.level = Logger::WARN
    double(Hobo.logger)
  end

  describe "initialization" do
    it "should provide default color scheme"
  end

  describe "ask" do
    it "should return default if in non-interactive mode" do
      ui = test_ui()
      ui.interactive = false
      ui.ask("Question", :default => "default").should match "default"
    end

    it "should raise error if no default provided in non-interactive mode" do
      ui = test_ui(:answer => "Answer\n")
      ui.interactive = false
      expect { ui.ask("Question") }.to raise_exception(Hobo::NonInteractiveError)
    end

    it "should format prompt to include default if provided" do
      output = StringIO.new
      output.should_receive(:write).with(/Question \[default\]:/)
      test_ui(:output => output).ask("Question", :default => "default")
    end

    it "should use default answer if given answer is empty" do
      test_ui(:answer => "\n").ask("Question", :default => "default").should match "default"
    end

    it "should handle stdin EOF (Ctrl+d)" do
      test_ui(:eof => true).ask("Question").should be_empty
    end

    it "should always return an instance of String" do
      test_ui(:answer => "Answer\n").ask("Question").should be_an_instance_of String
      test_ui(:answer => "\n").ask("Question", :default => "").should be_an_instance_of String
      test_ui(:answer => "\x04").ask("Question").should be_an_instance_of String
    end

    it "should support hidden text for password inputs"
  end

  describe "ask_choice" do
    it "should return default if in non-interactive mode" do
      ui = test_ui()
      ui.interactive = false
      ui.ask_choice("Question", ['default', 'non-default'], :default => "default").should match "default"
    end

    it "should raise error if no default provided in non-interactive mode" do
      ui = test_ui(:answer => "Answer\n")
      ui.interactive = false
      expect { ui.ask_choice("Question", ['one', 'two']) }.to raise_exception(Hobo::NonInteractiveError)
    end

    it "should format prompt to include default if provided"

    it "should give a choice prompt with each option in"

    it "should convert a number choice to its value if given" do
      test_ui(:answer => "2\n").ask_choice("Question", ['default', 'non-default'], :default => "default").should match "non-default"
    end

    it "should use default answer if given answer is empty" do
      test_ui(:answer => "\n").ask_choice("Question", ['default', 'non-default'], :default => "default").should match "default"
    end

    it "should handle stdin EOF (Ctrl+d)" do
      test_ui(:eof => true).ask_choice("Question", ['default', 'non-default']).should be_empty
    end

    it "should always return an instance of String" do
      test_ui(:answer => "Answer\n").ask_choice("Question", ['Answer']).should be_an_instance_of String
      test_ui(:answer => "\n").ask_choice("Question", ['Answer'], :default => "").should be_an_instance_of String
      test_ui(:answer => "\x04").ask_choice("Question", ['Answer']).should be_an_instance_of String
    end
  end

  describe "color" do
    it "should format message with ansi style" do
      ui = test_ui
      ui.use_color true
      ui.color("test", :red).should match /\e\[31mtest\e\[0m/
    end
  end

  describe "use_color" do
    it "should set the use of color" do
      ui = test_ui
      ui.use_color true
      ui.color("test", :red).should match /\e\[31mtest\e\[0m/
      ui.use_color false
      ui.color("test", :red).should match /^test$/
    end
  end

  describe "color_scheme" do
    it "should set the global color scheme if argument provided"
    it "should return the global color scheme"
  end

  describe "debug" do
    it "should send message to stdout" do
      output = StringIO.new
      output.should receive(:puts).with("test")
      test_ui(:output => output).debug("test")
    end

    it "should log to logger" do
      Hobo.logger.should_receive(:debug).with("test")
      test_ui.debug("test")
    end
  end

  describe "info" do
    it "should send message to stdout" do
      output = StringIO.new
      output.should receive(:puts).with("test")
      test_ui(:output => output).info("test")
    end

    it "should log to logger" do
      Hobo.logger.should_receive(:debug).with("test")
      test_ui.info("test")
    end
  end

  describe "warning" do
    it "should send message to stderr" do
      error = StringIO.new
      error.should receive(:puts).with("test")
      test_ui(:error => error).warning("test")
    end

    it "should log to logger" do
      Hobo.logger.should_receive(:debug).with("test")
      test_ui.warning("test")
    end
  end

  describe "error" do
    it "should send message to stderr" do
      error = StringIO.new
      error.should receive(:puts).with("test")
      test_ui(:error => error).error("test")
    end

    it "should log to logger" do
      Hobo.logger.should_receive(:debug).with("test")
      test_ui.error("test")
    end
  end

  describe "success" do
    it "should send message to stdout" do
      output = StringIO.new
      output.should receive(:puts).with("test")
      test_ui(:output => output).success("test")
    end

    it "should log to logger" do
      Hobo.logger.should_receive(:debug).with("test")
      test_ui.success("test")
    end
  end
end
