require 'spec_helper'

describe Hobo do
  describe 'project_path' do
    before do
      Hobo.project_path = nil
      FakeFS.activate!
    end

    after do
      FakeFS::FileSystem.clear
      FakeFS.deactivate!
    end

    it 'should return nil if not in project' do
      Hobo.project_path.should eq nil
    end

    it 'should return project directory if tools/hobo exists' do
      FileUtils.mkdir_p 'project/test/tools/hobo'
      Dir.chdir 'project/test' do
        Hobo.project_path.should eq '/project/test'
      end
    end

    it 'should traverse up directories search for tools/hobo' do
      FileUtils.mkdir_p 'project/test/tools/hobo'
      Dir.chdir 'project/test/tools/hobo' do
        Hobo.project_path.should eq '/project/test'
      end
    end

    it 'should memoize project path' do
      FileUtils.mkdir_p 'project/test/tools/hobo'
      Dir.chdir 'project/test/tools/hobo' do
        Hobo.project_path.should eq '/project/test'
      end

      # We remove the hobo directory to see if the path was memoized or not
      FileUtils.rmdir('project/test/tools/hobo')
      Dir.chdir 'project/test/tools' do
        Hobo.project_path.should eq '/project/test'
      end
    end
  end

  describe 'config_path' do
    it 'should be ~/.hobo' do
      Hobo.config_path.should eq File.join(ENV['HOME'], '.hobo')
    end
  end

  describe 'seed_cache_path' do
    it 'should be ~/.hobo/seeds' do
      Hobo.seed_cache_path.should eq File.join(ENV['HOME'], '.hobo', 'seeds')
    end
  end

  describe 'hobofile_path' do
    it 'should be project_path + Hobofile' do
      Hobo.hobofile_path.should eq File.join(Hobo.project_path, 'Hobofile')
    end
  end

  describe 'project_config_file' do
    it 'should be project_path + tools/hobo/config.yaml' do
      Hobo.project_config_file.should eq File.join(Hobo.project_path, 'tools', 'hobo', 'config.yaml')
    end
  end

  describe 'user_config_file' do
    it 'should be ~/.hobo/config.yaml' do
      Hobo.user_config_file.should eq File.join(Hobo.config_path, 'config.yaml')
    end
  end
end
