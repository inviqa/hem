require 'spec_helper'

describe Rake do
  cli = nil

  before do
    Rake::Task.clear
    Hem::Metadata.default :opts, []
    Hem::Metadata.default :desc, nil
    Hem::Metadata.reset_store
    Hem::Metadata.metadata = {}

    Hem.ui = double(Hem::Ui).as_null_object
    help = double(Hem::HelpFormatter).as_null_object
    host_check = double(Hem::Lib::HostCheck).as_null_object
    cli = Hem::Cli.new help: help, host_check: host_check

    FakeFS.activate!
  end

  after do
    FakeFS::FileSystem.clear
    FakeFS.deactivate!
  end

  describe "before hook" do

    it "should run block type task before specified task" do
      File.write('Hemfile', "
        task 'block-test' do
          Hem.ui.info 'test'
        end
        before 'block-test' do
          Hem.ui.info 'before'
        end"
      )

      Hem.ui.should_receive(:info).with('before')
      Hem.ui.should_receive(:info).with('test')

      cli.start ['block-test']
    end

    it "should run string type task before specified task" do
      File.write('Hemfile', "
        task 'string-test' do
          Hem.ui.info 'test'
        end
        task 'before' do
          Hem.ui.info 'before'
        end
        before 'string-test', 'before'
        "
      )

      Hem.ui.should_receive(:info).with('before')
      Hem.ui.should_receive(:info).with('test')

      cli.start ['string-test']
    end

    it "should run multiple string type tasks before specified task" do
      File.write('Hemfile', "
        task 'multiple-string-test' do
          Hem.ui.info 'test'
        end
        task 'before1' do
          Hem.ui.info 'before1'
        end
        task 'before2' do
          Hem.ui.info 'before2'
        end
        before 'multiple-string-test', ['before1', 'before2']
        "
      )

      Hem.ui.should_receive(:info).with('before1')
      Hem.ui.should_receive(:info).with('before2')
      Hem.ui.should_receive(:info).with('test')

      cli.start ['multiple-string-test']
    end

    it "should maintain all task metadata" do
      File.write('Hemfile', "
        option '--test', 'A test'
        desc 'A description'
        long_desc 'A long description'
        project_only
        hidden
        task 'metadata-test' do
          Hem.ui.info 'test'
        end

        task 'before' do
          Hem.ui.info 'before'
        end

        before 'metadata-test', 'before'
        "
      )

      cli.start ['metadata-test']

      Hem::Metadata.metadata['metadata-test'][:opts].should eql([["--test", "A test"]])
      Hem::Metadata.metadata['metadata-test'][:desc].should eql("A description")
      Hem::Metadata.metadata['metadata-test'][:long_desc].should eql("A long description")
      Hem::Metadata.metadata['metadata-test'][:project_only].should be(true)
      Hem::Metadata.metadata['metadata-test'][:hidden].should be(true)
    end
  end

  describe "after hook" do
    it "should run block type task after specified task" do
      File.write('Hemfile', "
        task 'block-test' do
          Hem.ui.info 'test'
        end
        after 'block-test' do
          Hem.ui.info 'after'
        end"
      )

      Hem.ui.should_receive(:info).with('test')
      Hem.ui.should_receive(:info).with('after')

      cli.start ['block-test']
    end

    it "should run string type task after specified task" do
      File.write('Hemfile', "
        task 'string-test' do
          Hem.ui.info 'test'
        end
        task 'after' do
          Hem.ui.info 'after'
        end
        after 'string-test', 'after'
        "
      )

      Hem.ui.should_receive(:info).with('test')
      Hem.ui.should_receive(:info).with('after')

      cli.start ['string-test']
    end

    it "should run multiple string type tasks after specified task" do
      File.write('Hemfile', "
        task 'multiple-string-test' do
          Hem.ui.info 'test'
        end
        task 'after1' do
          Hem.ui.info 'after1'
        end
        task 'after2' do
          Hem.ui.info 'after2'
        end
        after 'multiple-string-test', ['after1', 'after2']
        "
      )

      Hem.ui.should_receive(:info).with('test')
      Hem.ui.should_receive(:info).with('after1')
      Hem.ui.should_receive(:info).with('after2')

      cli.start ['multiple-string-test']
    end

    it "should maintain all task metadata" do
      File.write('Hemfile', "
        option '--test', 'A test'
        desc 'A description'
        long_desc 'A long description'
        project_only
        hidden
        task :'metadata-test' do
          Hem.ui.info 'test'
        end

        task 'after' do
          Hem.ui.info 'after'
        end

        after :'metadata-test', 'after'
        "
      )

      cli.start ['metadata-test']

      Hem::Metadata.metadata['metadata-test'][:opts].should eql([["--test", "A test"]])
      Hem::Metadata.metadata['metadata-test'][:desc].should eql("A description")
      Hem::Metadata.metadata['metadata-test'][:long_desc].should eql("A long description")
      Hem::Metadata.metadata['metadata-test'][:project_only].should be(true)
      Hem::Metadata.metadata['metadata-test'][:hidden].should be(true)
    end
  end

  describe 'invoke' do
    it "should invoke an existing task without args" do
      File.write('Hemfile', "
        task 'invoke-target'do
          Hem.ui.info 'invoked'
        end
        task 'invoker' do
          invoke('invoke-target')
        end
        "
      )

      Hem.ui.should_receive(:info).with('invoked')
      cli.start ['invoker']
    end

    it "should invoke an existing task with args" do
      File.write('Hemfile', "
        task 'invoke-target', [:arg1] do |task, args|
          Hem.ui.info args[:arg1]
        end
        task 'invoker' do
          invoke('invoke-target', 'arg1')
        end
        "
      )

      Hem.ui.should_receive(:info).with('arg1')
      cli.start ['invoker']
    end
  end
end
