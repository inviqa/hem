desc "VM related commands"
project_only
namespace :vm do
  def vagrantfile &block
    locate("*Vagrantfile", missing: "No Vagrantfile found") do
      yield
    end
  end

  desc "Start VM"
  task :start => [ 'deps:gems', 'deps:chef', 'deps:composer', 'vm:up', 'vm:start' ]

  desc "Stop VM"
  task :stop do
    vagrantfile do
      Hobo.ui.title "Stopping VM"
      bundle_shell "vagrant", "suspend", "--color", realtime: true, indent: 2
      Hobo.ui.separator
    end
  end

  desc "Rebuild VM"
  task :rebuild => [ 'vm:destroy', 'vm:start' ]

  desc "Destroy VM"
  task :destroy do
    vagrantfile do
      Hobo.ui.title "Stopping VM"
      bundle_shell "vagrant", "destroy", "--color", realtime: true, indent: 2
      Hobo.ui.separator
    end
  end

  task :up do
    vagrantfile do
      Hobo.ui.title "Starting vagrant VM"
      bundle_shell "vagrant", "up", "--no-provision", "--color", realtime: true, indent: 2
      Hobo.ui.separator
    end
  end

  task :provision do
     vagrantfile do
      Hobo.ui.title "Provisioning VM"
      bundle_shell "vagrant", "provision", "--color", realtime: true, indent: 2
      Hobo.ui.separator
    end
  end
end