require 'spec_helper'

describe Hobo::Lib::Seed::Seed do
  pwd = nil
  tmp_dir = nil

  before do
    tmp_dir = Dir.mktmpdir
    pwd = Dir.pwd
    Dir.chdir tmp_dir
    Hobo.ui = double(Hobo::Ui).as_null_object
  end

  after do
    Dir.chdir pwd
    FileUtils.remove_entry tmp_dir
  end

  def create_test_repo path, content
    FileUtils.mkdir_p path
    Dir.chdir path do
      `git init`
      `echo "#{content}" > test`
      `git add *`
      `git commit -m "test"`
    end
  end

  describe "update", :integration do
    it "should fetch the seed if it does not exist locally" do
      # Create test repo as seed remote
      remote_seed_path = File.join(tmp_dir, "seed_1")
      create_test_repo remote_seed_path, "does not exist locally"

      seed = Hobo::Lib::Seed::Seed.new 'seeds/seed_1', remote_seed_path
      seed.update

      # Repo is bare so we need to use git show to get contents
      `cd seeds/seed_1 && git show HEAD:test`.strip.should eq "does not exist locally"
    end

    it "should update the seed if it exists locally" do
      # Create test repo as seed remote
      remote_seed_path = File.join(tmp_dir, "seed_2")
      create_test_repo remote_seed_path, "does exist locally"

      # Clone seed to seed cache directory
      FileUtils.mkdir_p "seeds"
      `cd seeds && git clone #{remote_seed_path} seed_2 --mirror 2> /dev/null`

      # Update seed origin repo to give test something to update
      `cd seed_2 && echo "updated" > test && git add test && git commit -m "test"`

      seed = Hobo::Lib::Seed::Seed.new 'seeds/seed_2', remote_seed_path
      seed.update

      # Repo is bare so we need to use git show to get contents
      `cd seeds/seed_2 && git show HEAD:test`.strip.should eq "updated"
    end
  end

  describe "export", :integration do
    it "should export the seed contents to specified directory" do
      # Create test repo as seed remote
      remote_seed_path = File.join(tmp_dir, "seed_3")
      create_test_repo remote_seed_path, "exported"

      # Update seed and export
      seed = Hobo::Lib::Seed::Seed.new 'seeds/seed_3', remote_seed_path
      seed.update
      seed.export "exported"

      File.read("exported/test").strip.should eq "exported"
      File.exists?("exported/.git").should be false
    end

    it "should export seed submodules to the specified directory"
    it "should export a specifified git :ref"
  end

  describe "version", :integration do
    it "should return the git sha of the seed" do
      # Create test repo as seed remote
      remote_seed_path = File.join(tmp_dir, "seed_4")
      create_test_repo remote_seed_path, "version_test"

      # Update seed and export
      seed = Hobo::Lib::Seed::Seed.new 'seeds/seed_4', remote_seed_path
      seed.update

      seed.version.should eq `cd seeds/seed_4 && git rev-parse --short HEAD`.strip
    end
  end
end
