require 'hobo/error_handlers/friendly'
require 'hobo/ui'

describe Hobo::ErrorHandlers::Friendly do
  before do
    Hobo.ui = double(Hobo::Ui.new).as_null_object
    FakeFS.activate!
    FileUtils.mkdir '/tmp'
  end

  after do
    FakeFS::FileSystem.clear
    FakeFS.deactivate!
  end

  describe "handle" do
    it "should display specialized error for Interrupt" do
      error = Interrupt.new
      Hobo.ui.should_receive(:warning).with(/Caught Interrupt/)
      Hobo::ErrorHandlers::Friendly.new.handle(error)
    end

    it "should display specialized error for an external command error" do
      File.write("temp_log", "command output")
      output = Struct.new(:path).new
      output.path = "temp_log"
      error = Hobo::ExternalCommandError.new("command", 128, output)
      Hobo.ui.should_receive(:error).with(/The following external command appears to have failed \(exit status 128\)/)
      Hobo::ErrorHandlers::Friendly.new.handle(error)
    end

    it "should write command output to /tmp/hobo_error.log for external command error" do
      File.write("temp_log", "command output")
      output = Struct.new(:path).new
      output.path = "temp_log"
      error = Hobo::ExternalCommandError.new("command", 128, output)
      Hobo::ErrorHandlers::Friendly.new.handle(error)
      File.read(File.join(Dir.tmpdir, 'hobo_error.log')).should match "command output"
    end

    it "should display specialized error for invalid command or opt error" do
      error = Hobo::InvalidCommandOrOpt.new("command")
      Hobo.ui.should_receive(:error).with(/Invalid command or option specified: 'command'/)
      Hobo::ErrorHandlers::Friendly.new.handle(error)
    end

    it "should display specialized error for missing argument error" do
      error = Hobo::MissingArgumentsError.new("command", ["arg1"])
      Hobo.ui.should_receive(:error).with(/Not enough arguments for command/)
      Hobo::ErrorHandlers::Friendly.new.handle(error)
    end

    it "should display specialized error for user error" do
      error = Hobo::UserError.new("user error")
      Hobo.ui.should_receive(:error).with(/user error/)
      Hobo::ErrorHandlers::Friendly.new.handle(error)
    end

    it "should display generic error for other exception" do
      error = nil
      begin
        raise Exception.new("general error")
      rescue Exception => error
      end

      Hobo.ui.should_receive(:error).with(/An unexpected error has occured/)
      Hobo::ErrorHandlers::Friendly.new.handle(error)
    end

    it "should write error backtrace to /tmp/hobo_error.log for other exception" do
      error = nil
      begin
        raise Exception.new("general error")
      rescue Exception => error
      end

      Hobo::ErrorHandlers::Friendly.new.handle(error)
      File.read(File.join(Dir.tmpdir, 'hobo_error.log')).should match /\(Exception\) general error/
    end
  end
end