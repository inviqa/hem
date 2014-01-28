require 'rake'

require 'hobo/metadata'
require 'hobo/patches/rake'
require 'hobo/patches/slop'

require 'hobo/errors'
require 'hobo/cli'


describe Hobo::Cli do
  cli = nil
  help = nil

  before do
    Rake::Task.tasks.each do |task|
      task.clear
    end
    Hobo.ui = double(Hobo::Ui).as_null_object
    help = double(Hobo::HelpFormatter).as_null_object
    cli = Hobo::Cli.new help: help
  end

  describe "hobofile" do
    it "should load the hobofile if present" do
      cli.start []
      Rake::Task["test:non-interactive"].should_not be nil
    end
  end

  describe "command mapping" do
    it "should set command map on help formatter" do
      help.should_recieve('command_map=')
      cli.start ["test", "subcommand"]
    end
  end

  describe "metadata" do
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
  end

  describe "global options" do
    it "should set non-interactive mode in ui if --non-interactive" do
      Hobo.ui.should_receive('interactive=').with(false)
      cli.start(['--non-interactive'])
    end
  end

  describe "invocation" do
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
end