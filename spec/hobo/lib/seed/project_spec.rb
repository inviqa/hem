require 'spec_helper'
require 'hobo'

describe Hobo::Lib::Seed::Project do
  pwd = nil
  tmp_dir = nil
  default_config = {}

  before do
    tmp_dir = Dir.mktmpdir
    pwd = Dir.pwd
    Dir.chdir tmp_dir
    FileUtils.mkdir_p "project_path"
    FileUtils.touch "project_path/test"
    Hobo.ui = Hobo::Ui.new
    default_config = {
      :config_class => double(Hobo::Config::File).as_null_object,
      :replacer => double(Hobo::Lib::Seed::Replacer.new).as_null_object
    }
  end

  after do
    Dir.chdir pwd
    FileUtils.remove_entry tmp_dir
  end

  describe "setup" do
    it "should update seed before use" do
      seed = double(Hobo::Lib::Seed::Seed).as_null_object
      seed.should_receive :update

      project = Hobo::Lib::Seed::Project.new(default_config)

      project.setup(seed, { :project_path => "project_path", :seed => {}, :git_url => '.' })
    end

    it "should export seed to project directory" do
      seed = double(Hobo::Lib::Seed::Seed).as_null_object
      seed.should_recieve(:export).with("project_path")

      project = Hobo::Lib::Seed::Project.new(default_config)

      project.setup(seed, { :project_path => "project_path", :seed => {}, :git_url => '.' })
    end

    it "should save config in project" do
      seed = double(Hobo::Lib::Seed::Seed).as_null_object
      seed.should_recieve :export, "project_path"

      config_class = double(Hobo::Config::File).as_null_object
      config_class.should_recieve(:save).with("project_config_file")

      project = Hobo::Lib::Seed::Project.new(default_config.merge({ :project_config_file => "project_config_file" }))

      project.setup(seed, { :project_path => "project_path", :seed => {}, :git_url => '.' })
    end

    it "should initialize the project git repository" do
      seed = double(Hobo::Lib::Seed::Seed).as_null_object

      project = Hobo::Lib::Seed::Project.new(default_config)

      project.setup(seed, { :project_path => "project_path", :seed => {}, :git_url => '.' })
      expect { Hobo::Helper.shell("cd project_path && git status")}.not_to raise_error
    end

    it "should add the git url as the origin remote" do
      seed = double(Hobo::Lib::Seed::Seed).as_null_object

      project = Hobo::Lib::Seed::Project.new(default_config)

      project.setup(seed, { :project_path => "project_path", :seed => {}, :git_url => 'remote_url' })
      Hobo::Helper.shell("cd project_path && git remote show -n origin", :capture => true).should match /remote_url/
    end

    it "should load seed init file if present"
    it "should remove seed init file"

    it "should set hostname in config"
    it "should set asset bucket in config"
  end
end