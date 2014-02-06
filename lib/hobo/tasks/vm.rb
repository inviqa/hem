desc "VM related commands"
project_only
namespace :vm do
  def vagrantfile &block
    locate "*Vagrantfile" do
      yield
    end
  end

  desc "Start & provision VM"
  task :up => [ 'deps:gems', 'deps:chef', 'deps:composer', 'deps:vagrant_plugins', 'vm:start', 'vm:provision' ]

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
  task :start => [ "deps:gems" ] do
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
end