require 'hobo/help_formatter'

describe Hobo::HelpFormatter do
  help = nil
  slop = nil

  before do
    map = {}
    slop = Slop.new
    slop.instance_eval do
      opt "-g", "--global", "Global option"

      map["test"] = command "test" do
        description "Testing1"
        opt "-t", "--test", "Test description"
        opt "-x", "--longer-option", "Longer option"

        map["test:test"] = command "test" do
         description "Testing2"
         arg_list [:arg]
         opt "-a=", "--a-test=", "Arg with value"
         opt "-b=", "--b-test=", "Arg with optional value", argument: :optional
        end
      end
    end

    help = Hobo::HelpFormatter.new slop
    help.command_map = map
    HighLine.use_color = false
    Hobo.ui = Hobo::Ui.new
  end

  describe "help" do

    it "should return global help if no target passed" do
      help.help.should match(/test\s+Testing1/)
    end

    it "should return command help if target passed" do
      help.help(target: "test").should match /^Testing1$/
    end

    describe "usage format" do
      it "should include generic usage for global help" do
        help.help.should match /Usage:\n\s+rspec \[command\] \[options\]/
      end

      it "should include command usage for command help" do
        help.help(target: "test:test").should match /Usage:\n\s+rspec test test <arg> \[options\]/
      end
    end

    describe "option format" do
      it "should include short, long and description" do
        help.help(target: "test").should match /\s+-t, --test\s+Test description/
      end

      it "should append token value to options that take an argument" do
        help.help(target: "test:test").should match /--a-test=A-TEST/
      end

      it "should surround token value qith square brackets for option with optional argument" do
        help.help(target: "test:test").should match /--b-test=\[B-TEST\]/
      end

      it "should have description aligned to longest option or command" do
        len = "--longer-option".length - "--test".length + 4 # ALIGN_PAD
        help.help(target: "test").should match /\s+-t, --test\s{#{len}}Test description/
      end
    end

    describe "command format" do
      it "should have name and description" do
        help.help.should match /\s+test\s+Testing1/
      end
    end

    describe "global" do
      it "should include usage" do
        help.help.should match /Usage:/
      end

      it "should include global options" do
        help.help.should match /Global options:\n\s+-g/
      end

      it "should include top level command list" do
        help.help.should match /Commands:\n\s+test/
      end
    end

    describe "namespace" do
      it "should include usage" do
        help.help(target: "test").should match /Usage:/
      end

      it "should include global options" do
        help.help(target: "test").should match /Global options:/
      end

      it "should include namespace level command list" do
        help.help(target: "test").should match /Commands:/
      end
    end

    describe "command" do
      it "should include long command description if set"
      it "should fall back to short command description if long description not set"
      it "should not display extra blank lines if no description set"
      it "should include usage"
      it "should include global options"
      it "should include command options"
      it "shoult not include -h command option"
    end

    describe "options" do
      it "should include short option"
      it "should include long option"
      it "should include option description"
    end

    describe "alignment" do
      it "should align descriptions according to longest option or command"
    end

    describe "filtering" do
      it "should not show commands that do not have descriptions"
      it "should show commands that do not have descriptions if :all is set"
    end
  end
end