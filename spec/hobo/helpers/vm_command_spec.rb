require 'spec_helper'

describe Hobo::Helper do
  before do
    Hobo.project_config = DeepStruct.wrap({
      :hostname => "test_hostname",
      :mysql => {
        :username => "test_user",
        :password => "test_pass"
      },
      :vm => {
        :project_mount_path => '/'
      }
    })

    Hobo.ui = Hobo::Ui.new

    vmi_double = double(Hobo::Helper::VmInspector).as_null_object
    vmi_double.should_receive(:ssh_config).and_return({
      :ssh_host => 'fakehost',
      :ssh_user => 'fakeuser',
      :ssh_port => '999',
      :ssh_identity => 'fakeidentity'
    })

    Hobo::Helper::VmCommand.class_eval do
      class_variable_set '@@vm_inspector', vmi_double
    end
  end

  describe "vm_command" do
    it "should create a new vm command wrapper with specified command" do
      vm_command("my_command", :pwd => '/').to_s.should match /-c my_command/
    end

<<<<<<< HEAD
    it "should default to using a psuedo tty" do
      vm_command("my_command", :pwd => '/').to_s.should match /\s-t\s/
    end

    it "should default to vagrant user" do
      vm_command("my_command", :pwd => '/').to_s.should match /vagrant@/
    end

    it "should default to project host name" do
      vm_command("my_command", :pwd => '/').to_s.should match /@test_hostname/
=======
    it "should default to not using a psuedo tty" do
      vm_command("my_command", :pwd => '/').to_s.should_not match /\s-t\s/
    end

    it "should default to ssh_config user" do
      vm_command("my_command", :pwd => '/').to_s.should match /fakeuser@/
    end

    it "should default to ssh_config host name" do
      vm_command("my_command", :pwd => '/').to_s.should match /@fakehost/
>>>>>>> 0.0.6-bugfixes
    end

    it "should not wrap piped commands with echo by default" do
      c = vm_command("my_command", :pwd => '/')
      c << "test"
      c.to_s.should_not match /^echo test/
    end
  end

  describe "vm_mysql" do
    it "should use mysql command by default" do
      vm_mysql(:pwd => '/').to_s.should match /-c mysql/
    end

    it "should use project config mysql username & password if set" do
      vm_mysql(:pwd => '/').to_s.should match /-c mysql.*-utest_user.*-ptest_pass/
    end

    it "should not pass user / pass if project config mysql credentials not set" do
      Hobo.project_config = DeepStruct.wrap({})
<<<<<<< HEAD
      vm_mysql(:pwd => '/').to_s.should match /-c mysql'$/
    end

    it "should allow specifying the database in options" do
      vm_mysql(:pwd => '/', :db => "test_db").to_s.should match /-c mysql.*test_db'$/
=======
      vm_mysql(:pwd => '/').to_s.should match /-c mysql'/
    end

    it "should allow specifying the database in options" do
      vm_mysql(:pwd => '/', :db => "test_db").to_s.should match /-c mysql.*test_db'/
>>>>>>> 0.0.6-bugfixes
    end

    it "should enable auto echo of piped commands" do
      c = vm_mysql(:pwd => '/')
      c << "SELECT 1"
      c.to_s.should match /^echo SELECT\\ 1/
    end
  end

  describe "vm_shell" do
    it "should execute the command using the shell helper" do
      Hobo::Helper.class_eval do
        alias :old_shell :shell
        def shell command, opts
          command.to_s.should match /ssh.* -c my_command/
        end
      end

      vm_shell "my_command", :pwd => '/'

      Hobo::Helper.class_eval do
        remove_method :shell
        alias :shell :old_shell
      end
    end
  end
end
