
describe Hem::ErrorHandlers::Friendly do
  before do
    Hem.ui = double(Hem::Ui.new).as_null_object
    FakeFS.activate!
    FileUtils.mkdir '/tmp'
  end

  after do
    FakeFS::FileSystem.clear
    FakeFS.deactivate!
  end

  def faked_exception(error_template)
    error = nil
    begin
      raise error_template
    rescue Exception => error
    end

    return error
  end

  describe "handle" do
    it "should display specialized error for Interrupt" do
      error = faked_exception(Interrupt.new)
      Hem.ui.should_receive(:warning).with(/Caught Interrupt/)
      Hem::ErrorHandlers::Friendly.new.handle(error)
    end

    it "should display specialized error for an external command error" do
      File.write("temp_log", "command output")
      output = Struct.new(:path).new
      output.path = "temp_log"

      error = faked_exception Hem::ExternalCommandError.new("command", 128, output)

      Hem.ui.should_receive(:error).with(/The following external command appears to have failed \(exit status 128\)/)
      Hem::ErrorHandlers::Friendly.new.handle(error)
    end

    it "should write command output to /tmp/hem_error.log for external command error" do
      File.write("temp_log", "command output")
      output = Struct.new(:path).new
      output.path = "temp_log"

      error = faked_exception Hem::ExternalCommandError.new("command", 128, output)

      Hem::ErrorHandlers::Friendly.new.handle(error)
      File.read(File.join(Dir.tmpdir, 'hem_error.log')).should match "command output"
    end

    it "should display specialized error for invalid command or opt error" do
      error = faked_exception Hem::InvalidCommandOrOpt.new("command")
      Hem.ui.should_receive(:error).with(/Invalid command or option specified: 'command'/)
      Hem::ErrorHandlers::Friendly.new.handle(error)
    end

    it "should display specialized error for missing argument error" do
      error = faked_exception Hem::MissingArgumentsError.new("command", ["arg1"])
      Hem.ui.should_receive(:error).with(/Not enough arguments for command/)
      Hem::ErrorHandlers::Friendly.new.handle(error)
    end

    it "should display specialized error for user error" do
      error = faked_exception Hem::UserError.new("user error")
      Hem.ui.should_receive(:error).with(/user error/)
      Hem::ErrorHandlers::Friendly.new.handle(error)
    end

    it "should display generic error for other exception" do
      error = faked_exception Exception.new("general error")
      Hem.ui.should_receive(:error).with(/An unexpected error has occured/)
      Hem::ErrorHandlers::Friendly.new.handle(error)
    end

    it "should write error backtrace to /tmp/hem_error.log for other exception" do
      error = faked_exception Exception.new("general error")
      Hem::ErrorHandlers::Friendly.new.handle(error)
      File.read(File.join(Dir.tmpdir, 'hem_error.log')).should match /\(Exception\) general error/
    end

    it "should return exit code according to exit_code_map" do
      File.write("temp_log", "command output")
      output = Struct.new(:path).new
      output.path = "temp_log"

      Hem::ErrorHandlers::Friendly.new.handle(faked_exception Interrupt.new).should eq 1
      Hem::ErrorHandlers::Friendly.new.handle(faked_exception Hem::ExternalCommandError.new("command", 128, output)).should eq 3
      Hem::ErrorHandlers::Friendly.new.handle(faked_exception Hem::InvalidCommandOrOpt.new("command")).should eq 4
      Hem::ErrorHandlers::Friendly.new.handle(faked_exception Hem::MissingArgumentsError.new("command", ["arg1"])).should eq 5
      Hem::ErrorHandlers::Friendly.new.handle(faked_exception Hem::UserError.new("user error")).should eq 6
      Hem::ErrorHandlers::Friendly.new.handle(faked_exception Hem::ProjectOnlyError.new).should eq 7
      Hem::ErrorHandlers::Friendly.new.handle(faked_exception Exception.new "general").should eq 128
    end
  end
end
