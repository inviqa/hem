require 'spec_helper'

describe Hobo do
  describe "in_project?" do
    it "should return true if project path detected" do
      Hobo.project_path = "test"
      Hobo.in_project?.should be true
    end

    it "should return false if no project path detected" do
      Hobo.project_path = false
      Hobo.in_project?.should be false
    end
  end

  describe "progress" do
    def progress_mock file, increment, total, type
      out = double(StringIO.new).as_null_object
      out.stub(:tty?).and_return(true)
      Hobo.progress(file, increment, total, type, :throttle_rate => nil, :output => out)
    end

    before do
      Hobo.project_bar_cache = {}
    end

    it "should create new progress bar if one does not exist" do
      bar = progress_mock("test", 0, 10, :update)
      bar.to_s.should match /^test.*0%/
    end

    it "should force width to 79 if windows" do
      Gem.should_receive(:win_platform?).and_return(true)
      bar = progress_mock("test:79", 0, 10, :update)
      bar.to_s.length.should eq 79
    end

    it "should update progress bar if type :update" do
      bar = progress_mock("test:update", 0, 10, :update)
      bar.to_s.should match /^test:update.*0%/

      Hobo.progress("test:update", 1, 10, :update)
      bar.to_s.should match /^test.update.*10%/
    end

    it "should increment progress by specified amount if type :update" do
      bar = progress_mock("test:increment", 0, 10, :update)
      bar.to_s.should match /^test:increment.*0%/

      Hobo.progress("test:increment", 1, 10, :update)
      bar.to_s.should match /^test:increment.*10%/

      Hobo.progress("test:increment", 1, 10, :update)
      bar.to_s.should match /^test:increment.*20%/
    end

    it "should finalize progress bar if type :finish" do
      bar = progress_mock("test:finish", 0, 10, :update)
      bar.to_s.should match /^test:finish.*0%/
      Hobo.progress("test:finish", 10, 10, :update)
      Hobo.progress("test:finish", 10, 10, :finish)
      bar.to_s.should match /^test:finish.*100%.*Time/
    end

    it "should set fixed format" do
      bar = progress_mock("test:format", 1, 10, :update)
      bar.to_s.should match /^test:format \[=+\s+\]\s+10%\s+ETA: 00:00:00/
    end

    it "should use filename as title" do
      bar = progress_mock("some/path/to/filename.ext", 1, 10, :update)
      bar.to_s.should match /^filename\.ext/
    end
  end
end
