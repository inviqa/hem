
describe Hem do
  describe 'project_path' do
    before do
      Hem.project_path = nil
      FakeFS.activate!
    end

    after do
      FakeFS::FileSystem.clear
      FakeFS.deactivate!
    end

    it 'should return nil if not in project' do
      Hem.project_path.should eq nil
    end

    it 'should return project directory if tools/hem exists' do
      FileUtils.mkdir_p 'project/test/tools/hem'
      Dir.chdir 'project/test' do
        Hem.project_path.should eq '/project/test'
      end
    end

    it 'should traverse up directories search for tools/hem' do
      FileUtils.mkdir_p 'project/test/tools/hem'
      Dir.chdir 'project/test/tools/hem' do
        Hem.project_path.should eq '/project/test'
      end
    end

    it 'should memoize project path' do
      FileUtils.mkdir_p 'project/test/tools/hem'
      Dir.chdir 'project/test/tools/hem' do
        Hem.project_path.should eq '/project/test'
      end

      # We remove the hem directory to see if the path was memoized or not
      FileUtils.rmdir('project/test/tools/hem')
      Dir.chdir 'project/test/tools' do
        Hem.project_path.should eq '/project/test'
      end
    end
  end

  describe 'config_path' do
    it 'should be ~/.hem' do
      Hem.config_path.should eq File.join(ENV['HOME'], '.hem')
    end
  end

  describe 'seed_cache_path' do
    it 'should be ~/.hem/seeds' do
      Hem.seed_cache_path.should eq File.join(ENV['HOME'], '.hem', 'seeds')
    end
  end

  describe 'hemfile_path' do
    it 'should be project_path + Hemfile' do
      Hem.hemfile_path.should eq File.join(Hem.project_path, 'Hemfile')
    end
  end

  describe 'project_config_file' do
    it 'should be project_path + tools/hem/config.yaml' do
      Hem.project_config_file.should eq File.join(Hem.project_path, 'tools', 'hem', 'config.yaml')
    end
  end

  describe 'user_config_file' do
    it 'should be ~/.hem/config.yaml' do
      Hem.user_config_file.should eq File.join(Hem.config_path, 'config.yaml')
    end
  end
end
