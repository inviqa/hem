require 'hobo/error_handlers/debug'

describe Hobo::ErrorHandlers::Debug do
  describe "handle" do
    it "should re-raise the error" do
      exception = Exception.new
      expect { Hobo::ErrorHandlers::Debug.new.handle(exception) }.to raise_error exception
    end
  end
end