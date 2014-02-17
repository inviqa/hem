require 'hobo/config'
require 'hobo/logging'
require 'hobo/ui'
require 'hobo/patches/deepstruct'
require 'hobo/helper/vm_command'


describe Hobo::Helper do
  before do
    Hobo.project_config = DeepStruct.wrap({
      :hostname => "test_hostname",
      :mysql => {
        :username => "test_user",
        :password => "test_pass"
      }
    })
  end

  describe "vm_command" do
    it "should create a new vm command wrapper with specified command" do
      vm_command("my_command").to_s.should match /-- my_command/
    end

    it "should default to using a psuedo tty" do
      vm_command("my_command").to_s.should match /\s-t\s/
    end

    it "should default to vagrant user" do
      vm_command("my_command").to_s.should match /vagrant@/
    end

    it "should default to project host name" do
      vm_command("my_command").to_s.should match /@test_hostname/
    end

    it "should not wrap piped commands with echo by default" do
      c = vm_command("my_command")
      c << "test"
      c.to_s.should_not match /^echo test/
    end
  end

  describe "vm_mysql" do
    it "should use mysql command by default" do
      vm_mysql.to_s.should match /-- mysql/
    end

    it "should use project config mysql username & password if set" do
      vm_mysql.to_s.should match /-- mysql.*-utest_user.*-ptest_pass/
    end

    it "should default to root/root if project config mysql credentials not set" do
      Hobo.project_config = DeepStruct.wrap({})
      vm_mysql.to_s.should match /-- mysql.*-uroot.*-proot/
    end

    it "should allow specifying the database in options" do
      vm_mysql(:db => "test_db").to_s.should match /-- mysql.*test_db$/
    end

    it "should enable auto echo of piped commands" do
      c = vm_mysql
      c << "SELECT 1"
      c.to_s.should match /^echo SELECT\\ 1/
    end
  end

  describe "vm_shell" do
    it "should execute the command using the shell helper" do
      Hobo::Helper.class_eval do
        alias :old_shell :shell
        def shell command
          command.should match /ssh.* -- my_command/
        end
      end

      vm_shell "my_command"

      Hobo::Helper.class_eval do
        remove_method :shell
        alias :shell :old_shell
      end
    end
  end
end