
describe Hem::ErrorHandlers::Debug do
  before do
    Hem.ui = double(Hem::Ui.new).as_null_object
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
    it "should dump the error" do
      error = nil
      begin
        raise Exception.new('error_message')
      rescue Exception => error
      end

      Hem.ui.should_receive(:error).with(/\(Exception\).*error_message.*debug_spec.rb.*/m)
      Hem::ErrorHandlers::Debug.new.handle(error)
    end

    it "should return exit code according to exit_code_map" do
      File.write("temp_log", "command output")
      output = Struct.new(:path).new
      output.path = "temp_log"

      Hem::ErrorHandlers::Debug.new.handle(faked_exception Interrupt.new).should eq 1
      Hem::ErrorHandlers::Debug.new.handle(faked_exception Hem::ExternalCommandError.new("command", 128, output)).should eq 3
      Hem::ErrorHandlers::Debug.new.handle(faked_exception Hem::InvalidCommandOrOpt.new("command")).should eq 4
      Hem::ErrorHandlers::Debug.new.handle(faked_exception Hem::MissingArgumentsError.new("command", ["arg1"])).should eq 5
      Hem::ErrorHandlers::Debug.new.handle(faked_exception Hem::UserError.new("user error")).should eq 6
      Hem::ErrorHandlers::Debug.new.handle(faked_exception Hem::ProjectOnlyError.new).should eq 7
      Hem::ErrorHandlers::Debug.new.handle(faked_exception Exception.new "general").should eq 128
    end
  end
end
