require 'hobo/null'

describe Hobo::Null do
  it "should return itself for any method call" do
    null = Hobo::Null.new
    null["test"].should eq null
    null.test.should eq null
    (null + null).should eq null
  end

  it "should convert to identity of types" do
    null = Hobo::Null.new
    null.to_s.should match ""
    null.to_i.should eq 0
    null.to_f.should eq 0.0
    null.to_a.should eq []
  end

  describe "maybe" do
    it "should return nil if nil?" do
      maybe(nil).should eq nil
      maybe(Hobo::Null.new).should eq nil
    end

    it "should return value for !nil?" do
      maybe(true).should eq true
      maybe("").should eq ""
      maybe(1).should eq 1
    end
  end
end