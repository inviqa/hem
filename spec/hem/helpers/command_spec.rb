
describe Hem::Helper do
  before do
    Hem.project_config = DeepStruct.wrap({
      :hostname => "test_hostname",
      :mysql => {
        :username => "test_user",
        :password => "test_pass"
      },
      :vm => {
        :project_mount_path => '/'
      }
    })

    Hem.user_config = DeepStruct.wrap({})

    Hem.ui = Hem::Ui.new

    vmi_double = double(Hem::Lib::Vm::Inspector).as_null_object
    vmi_double.should_receive(:ssh_config).and_return <<-eos
Host default
  HostName 127.0.0.1
  User vagrant
  Port 2222
  UserKnownHostsFile /dev/null
  StrictHostKeyChecking no
  PasswordAuthentication no
  IdentityFile "/path/to/project/tools/vagrant/.vagrant/machines/default/virtualbox/private_key"
  IdentitiesOnly yes
  LogLevel FATAL
  ForwardAgent yes
    eos

    Hem::Lib::Vm::Command.class_eval do
      class_variable_set '@@vm_inspector', vmi_double
    end
  end

  describe "create_command" do
    it "should create a new vm command wrapper with specified command" do
      create_command("my_command", :pwd => '/').to_s.should match /-c my_command/
    end

    it "should default to not using a psuedo tty" do
      create_command("my_command", :pwd => '/').to_s.should_not match /\s-t\s/
    end

    it "should use injected config" do
      create_command("my_command", :pwd => '/').to_s.should match /-F [^-][^ ]*/
    end

    it "should use default host" do
      create_command("my_command", :pwd => '/').to_s.should match /\ default/
    end

    it "should not wrap piped commands with echo by default" do
      c = create_command("my_command", :pwd => '/')
      c << "test"
      c.to_s.should_not match /^echo test/
    end
  end

  describe "create_mysql_command" do
    it "should use mysql command by default" do
      create_mysql_command(:pwd => '/').to_s.should match /-c mysql/
    end

    it "should use project config mysql username & password if set" do
      create_mysql_command(:pwd => '/').to_s.should match /-c mysql.*-utest_user.*-ptest_pass/
    end

    it "should not pass user / pass if project config mysql credentials not set" do
      Hem.project_config = DeepStruct.wrap({})
      create_mysql_command(:pwd => '/').to_s.should match /-c mysql'/
    end

    it "should allow specifying the database in options" do
      create_mysql_command(:pwd => '/', :db => "test_db").to_s.should match /-c mysql.*test_db'/
    end

    it "should enable auto echo of piped commands" do
      c = create_mysql_command(:pwd => '/')
      c << "SELECT 1"
      c.to_s.should match /echo\\ SELECT\\\\\\\\\\ 1\\ \\\|/
    end
  end

  describe "run_command" do
    it "should execute the command using the shell helper when refactored"
  end
end
