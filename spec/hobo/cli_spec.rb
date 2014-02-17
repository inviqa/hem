require 'spec_helper'
require 'rake'
require 'hobo'

describe Hobo::Cli do
  cli = nil
  help = nil
  hobofile = nil

  before do
    Rake::Task.tasks.each do |task|
      task.clear
    end
    Hobo.ui = double(Hobo::Ui).as_null_object
    help = double(Hobo::HelpFormatter).as_null_object
    cli = Hobo::Cli.new help: help

    hobofile = File.read(File.join(File.dirname(__FILE__), '../../Hobofile'))

    Hobo.project_path = nil
    FakeFS.activate!

    File.write('Hobofile', hobofile)
  end

  after do
    FakeFS::FileSystem.clear
    FakeFS.deactivate!
  end

  it "should load the hobofile if present" do
    cli.start []
    Rake::Task["test:non-interactive"].should_not be nil
  end

  it "should load the user hobofile if present" do
    FileUtils.mkdir_p(File.dirname(Hobo.user_hobofile_path))
    File.write(Hobo.user_hobofile_path, "namespace :user do\ntask :user do\nend\nend")
    cli.start []
    Rake::Task["user:user"].should_not be nil
  end

  it "should load project config if present" do
    FileUtils.mkdir_p("tools/hobo/")
    File.write("tools/hobo/config.yaml", YAML::dump({ :project => "project_config" }))
    cli.start []
    Hobo.project_config.project.should match "project_config"
  end

  it "should load user config if present" do
    FileUtils.mkdir_p(Hobo.config_path)
    File.write(Hobo.user_config_file, YAML::dump({ :user => "user_config" }))
    cli.start []
    Hobo.user_config.user.should match "user_config"
  end

  it "should set command map on help formatter" do
    help.should_recieve('command_map=')
    cli.start ["test", "subcommand"]
  end

  it "should propagate description metadata" do
    map = nil
    allow(help).to receive("command_map=") { |i| map = i }
    cli.start []
    map["test:metadata"].description.should match "description"
  end

  it "should propagate long description metadata" do
    map = nil
    allow(help).to receive("command_map=") { |i| map = i }
    cli.start []
    map["test:metadata"].long_description.should match "long description"
  end

  it "should propagate arg list metadata" do
    map = nil
    allow(help).to receive("command_map=") { |i| map = i }
    cli.start []
    expect(map["test:metadata"].arg_list).to eq [ :arg ]
  end

  it "should propagate option metadata" do
    map = nil
    allow(help).to receive("command_map=") { |i| map = i }
    cli.start []
    map["test:metadata"].options.length.should be 2
    expect(map["test:metadata"].options.map(&:short)).to eq [ 'o', 'h' ]
    expect(map["test:metadata"].options.map(&:long)).to eq [ 'option', 'help' ]
    expect(map["test:metadata"].options.map(&:description)).to eq [ 'Option description', 'Display help' ]
  end

  it "should propagate hidden metadata" do
    map = nil
    allow(help).to receive("command_map=") { |i| map = i }
    cli.start []
    map["test:metadata"].hidden.should be true
  end

  it "should set non-interactive mode in ui if --non-interactive" do
    Hobo.ui.should_receive('interactive=').with(false)
    cli.start(['--non-interactive'])
  end

  it "should show help if no args or opts passed" do
    help.should_receive(:help)
    cli.start([])
  end

  it "should show help for --help" do
    help.should_receive(:help)
    cli.start ["--help"]
  end

  it "should execute a top level command" do
    Hobo.ui.should_recieve(:info).with("top level")
    cli.start ["top-level"]
  end

  it "should execute a subcommand" do
    Hobo.ui.should_recieve(:info).with("Subcommand test")
    cli.start ["test", "subcommand"]
  end

  it "should show help for a namespace" do
    help.should_receive(:help).with(all: nil, target: "test")
    cli.start ["test"]
  end

  it "should show command help for --help" do
    help.should_receive(:help).with(all: nil, target: "test:subcommand")
    cli.start ["test", "subcommand", "--help"]
  end

  it "should propagate --all option to help" do
    help.should_receive(:help).with(all: true, target: "test")
    cli.start ["test", "--all"]
  end

  it "should propagate command opts to command" do
    Hobo.ui.should_receive(:info).with("1234")
    cli.start ["test", "option-test", "--testing=1234"]
  end

  it "should propagate arguments to command" do
    Hobo.ui.should_receive(:info).with("1234")
    cli.start ["test", "argument-test", "1234"]
  end

  it "should raise an exception if not enough arguments were passed" do
    expect { cli.start(["test", "metadata"]) }.to raise_error Hobo::MissingArgumentsError
  end
end