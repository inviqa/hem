desc "VM related commands"
project_only
namespace :vm do
  def vagrantfile &block
    locate "*Vagrantfile" do
      yield
    end
  end

  desc "Start & provision VM"
  task :up => [ 'deps:chef', 'deps:composer', 'assets:download', 'vm:start', 'vm:provision', 'assets:apply' ]

  desc "Stop VM"
  task :stop => [ "deps:gems" ] do
    vagrantfile do
      Hobo.ui.title "Stopping VM"
      bundle_shell "vagrant", "suspend", "--color", realtime: true, indent: 2
      Hobo.ui.separator
    end
  end

  desc "Rebuild VM"
  task :rebuild => [ 'vm:destroy', 'vm:up' ]

  desc "Destroy VM"
  task :destroy => [ "deps:gems" ] do
    vagrantfile do
      Hobo.ui.title "Destroying VM"
      bundle_shell "vagrant", "destroy", "--force", "--color", realtime: true, indent: 2
      Hobo.ui.separator
    end
  end

  desc "Start VM without provision"
  task :start => [ "deps:gems", "deps:vagrant_plugins" ] do
    vagrantfile do
      Hobo.ui.title "Starting vagrant VM"
      bundle_shell "vagrant", "up", "--no-provision", "--color", realtime: true, indent: 2
      Hobo.ui.separator
    end
  end

  desc "Provision VM"
  task :provision => [ "deps:gems" ] do
     vagrantfile do
      Hobo.ui.title "Provisioning VM"
      bundle_shell "vagrant", "provision", "--color", realtime: true, indent: 2
      Hobo.ui.separator
    end
  end

  desc "Open an SSH connection"
  task :ssh do
    exec vm_command
  end

  desc "Open a MySQL cli connection"
  task :mysql do
    exec vm_mysql
  end

  desc "Open a Redis cli connection"
  task :redis do
    exec vm_command "redis-cli"
  end
end