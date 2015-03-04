desc "Shared VM related tasks"
hidden true
namespace 'sharedvm' do
  desc "Start the shared VM"
  task 'start' do
    Dir.chdir Hobo.shared_vm_home do
      unless shared_vm_started?
        Hobo.ui.section "Starting shared VM" do
          puts `pwd`
          shell 'vagrant up', :realtime => true, :indent => 2
          shell 'vagrant ssh-config > shared_vm.ssh_config'
        end
      else
        Hobo.ui.warning "Shared VM already started, skipping\n"
      end
    end
  end

  desc "Stop the shared VM"
  task 'stop' do
    Hobo.ui.section "Stopping shared VM" do
      Dir.chdir Hobo.shared_vm_home do
        shell 'vagrant halt', :realtime => true, :indent => 2
        shell 'rm -f shared_vm.ssh_config'
      end
    end
  end

  desc "Destroy the shared VM"
  task 'destroy' do
    Hobo.ui.section "Destroying shared VM" do
      Dir.chdir Hobo.shared_vm_home do
        shell 'vagrant destroy --force', :realtime => true, :indent => 2
        shell 'rm -f shared_vm.ssh_config'
      end
    end
  end

  desc "SSH to shared VM"
  task 'connect' do
    Dir.chdir Hobo.shared_vm_home do
      exec 'ssh -F shared_vm.ssh_config default'
    end
  end

  desc "Rebuild the shared VM"
  task 'rebuild' => ['sharedvm:destroy', 'sharedvm:start']

  desc "Reset docker & kubernetes"
  task 'reset-docker' do
    services = ['kube-kubelet', 'kube-apiserver', 'kube-controller-manager', 'kube-proxy', 'kube-scheduler', 'docker']

    Hobo.ui.success "Stopping services"
    services.each do |s|
      shared_vm_shell "sudo systemctl stop #{s}"
    end

    Hobo.ui.success "Wiping kubernetes state"
    shared_vm_shell 'curl localhost:4001/v2/keys/registry?recursive=true -X DELETE', :capture => true

    Hobo.ui.success "Restarting services"
    services.reverse.each do |s|
      shared_vm_shell "sudo systemctl start #{s}"
    end

    Hobo.ui.success "Restarting shared_vm pods"
    shared_vm_shell 'kubectl -nshared-vm-system create -f /kubernetes/http-router/'
    shared_vm_shell 'kubectl create -f /kubernetes/elk/'
  end
end
