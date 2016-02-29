
describe Hem::Helper do
  describe "convert_args" do
    it "should parse empty arguments" do
      arg_list = {
        'a' => {as: String, optional: false},
        'b' => {as: String, optional: false},
      }
      expect(convert_args('my_task', [], {})).to eq([])
    end

    it "should parse mandatory arguments" do
      arg_list = {
        'a' => {as: String, optional: false},
        'b' => {as: String, optional: false},
      }
      expect(convert_args('my_task', [1,2], arg_list)).to eq([1,2])
    end

    it "should parse optional arguments" do
      arg_list = {
        'a' => {as: String, optional: true},
        'b' => {as: String, optional: true},
      }
      expect(convert_args('my_task', [1], arg_list)).to eq([1, nil])
    end

    it "should parse array arguments" do
      arg_list = {
        'a' => {as: Array},
      }
      expect(convert_args('my_task', [1,2,3], arg_list)).to eq([[1,2,3]])
    end

    it "should parse a optional string then a optional array" do
      arg_list = {
        'a' => {as: String, optional: true},
        'b' => {as: Array, optional: true},
      }
      expect(convert_args('my_task', [1,2,3], arg_list)).to eq([1,[2,3]])
    end

    it "should throw exception on missing mandatory arguments" do
      arg_list = {
        'a' => {as: String, optional: false},
      }
      expect{convert_args('my_task', [], arg_list)}.to raise_error(Hem::MissingArgumentsError)
    end

    it "should throw exception if more input than arguments" do
      arg_list = {
        'a' => {as: String, optional: false},
      }
      expect{convert_args('my_task', [1,2], arg_list)}.to raise_error(Hem::InvalidCommandOrOpt)
    end
  end
end
