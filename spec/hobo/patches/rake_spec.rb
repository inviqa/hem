require 'spec_helper'

describe Rake do
  cli = nil

  before do
    Rake::Task.clear
    Hobo::Metadata.default :opts, []
    Hobo::Metadata.default :desc, nil
    Hobo::Metadata.reset_store
    Hobo::Metadata.metadata = {}

    Hobo.ui = double(Hobo::Ui).as_null_object
    help = double(Hobo::HelpFormatter).as_null_object
    host_check = double(Hobo::Lib::HostCheck).as_null_object
    cli = Hobo::Cli.new help: help, host_check: host_check

    FakeFS.activate!
  end

  after do
    FakeFS::FileSystem.clear
    FakeFS.deactivate!
  end

  describe "before hook" do

    it "should run block type task before specified task" do
      File.write('Hobofile', "
        task 'block-test' do
          Hobo.ui.info 'test'
        end
        before 'block-test' do
          Hobo.ui.info 'before'
        end"
      )

      Hobo.ui.should_receive(:info).with('before')
      Hobo.ui.should_receive(:info).with('test')

      cli.start ['block-test']
    end

    it "should run string type task before specified task" do
      File.write('Hobofile', "
        task 'string-test' do
          Hobo.ui.info 'test'
        end
        task 'before' do
          Hobo.ui.info 'before'
        end
        before 'string-test', 'before'
        "
      )

      Hobo.ui.should_receive(:info).with('before')
      Hobo.ui.should_receive(:info).with('test')

      cli.start ['string-test']
    end

    it "should run multiple string type tasks before specified task" do
      File.write('Hobofile', "
        task 'multiple-string-test' do
          Hobo.ui.info 'test'
        end
        task 'before1' do
          Hobo.ui.info 'before1'
        end
        task 'before2' do
          Hobo.ui.info 'before2'
        end
        before 'multiple-string-test', ['before1', 'before2']
        "
      )

      Hobo.ui.should_receive(:info).with('before1')
      Hobo.ui.should_receive(:info).with('before2')
      Hobo.ui.should_receive(:info).with('test')

      cli.start ['multiple-string-test']
    end

    it "should maintain all task metadata" do
      File.write('Hobofile', "
        option '--test', 'A test'
        desc 'A description'
        long_desc 'A long description'
        project_only
        hidden
        task 'metadata-test' do
          Hobo.ui.info 'test'
        end

        task 'before' do
          Hobo.ui.info 'before'
        end

        before 'metadata-test', 'before'
        "
      )

      cli.start ['metadata-test']
      
      Hobo::Metadata.metadata['metadata-test'][:opts].should eql([["--test", "A test"]])
      Hobo::Metadata.metadata['metadata-test'][:desc].should eql("A description")
      Hobo::Metadata.metadata['metadata-test'][:long_desc].should eql("A long description")
      Hobo::Metadata.metadata['metadata-test'][:project_only].should be(true)
      Hobo::Metadata.metadata['metadata-test'][:hidden].should be(true)
    end
  end

  describe "after hook" do
    it "should run block type task after specified task" do
      File.write('Hobofile', "
        task 'block-test' do
          Hobo.ui.info 'test'
        end
        after 'block-test' do
          Hobo.ui.info 'after'
        end"
      )

      Hobo.ui.should_receive(:info).with('test')
      Hobo.ui.should_receive(:info).with('after')

      cli.start ['block-test']
    end

    it "should run string type task after specified task" do
      File.write('Hobofile', "
        task 'string-test' do
          Hobo.ui.info 'test'
        end
        task 'after' do
          Hobo.ui.info 'after'
        end
        after 'string-test', 'after'
        "
      )

      Hobo.ui.should_receive(:info).with('test')
      Hobo.ui.should_receive(:info).with('after')

      cli.start ['string-test']
    end

    it "should run multiple string type tasks after specified task" do
      File.write('Hobofile', "
        task 'multiple-string-test' do
          Hobo.ui.info 'test'
        end
        task 'after1' do
          Hobo.ui.info 'after1'
        end
        task 'after2' do
          Hobo.ui.info 'after2'
        end
        after 'multiple-string-test', ['after1', 'after2']
        "
      )

      Hobo.ui.should_receive(:info).with('test')
      Hobo.ui.should_receive(:info).with('after1')
      Hobo.ui.should_receive(:info).with('after2')

      cli.start ['multiple-string-test']
    end

    it "should maintain all task metadata" do
      File.write('Hobofile', "
        option '--test', 'A test'
        desc 'A description'
        long_desc 'A long description'
        project_only
        hidden
        task :'metadata-test' do
          Hobo.ui.info 'test'
        end

        task 'after' do
          Hobo.ui.info 'after'
        end

        after :'metadata-test', 'after'
        "
      )

      cli.start ['metadata-test']
      
      Hobo::Metadata.metadata['metadata-test'][:opts].should eql([["--test", "A test"]])
      Hobo::Metadata.metadata['metadata-test'][:desc].should eql("A description")
      Hobo::Metadata.metadata['metadata-test'][:long_desc].should eql("A long description")
      Hobo::Metadata.metadata['metadata-test'][:project_only].should be(true)
      Hobo::Metadata.metadata['metadata-test'][:hidden].should be(true)
    end
  end

  describe 'invoke' do
    it "should invoke an existing task without args" do
      File.write('Hobofile', "
        task 'invoke-target'do
          Hobo.ui.info 'invoked'
        end
        task 'invoker' do
          invoke('invoke-target')
        end
        "
      )

      Hobo.ui.should_receive(:info).with('invoked')
      cli.start ['invoker']
    end

    it "should invoke an existing task with args" do
      File.write('Hobofile', "
        task 'invoke-target', [:arg1] do |task, args|
          Hobo.ui.info args[:arg1]
        end
        task 'invoker' do
          invoke('invoke-target', 'arg1')
        end
        "
      )

      Hobo.ui.should_receive(:info).with('arg1')
      cli.start ['invoker']
    end
  end
end
