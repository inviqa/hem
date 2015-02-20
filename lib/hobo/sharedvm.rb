module Hobo
  class << self
    def shared_vm_home
      File.expand_path("~/.hobo/shared_vm")
    end

    def shared_vm_mount
      maybe(Hobo.user_config.shared_vm.mount) || "/projects"
    end

    def host_to_shared_vm_path path
      return nil unless path =~ /^#{shared_vm_mount}/
      path.gsub(/^#{shared_vm_mount}/, "/vagrant")
    end

    def shared_vm_project_path
      host_to_shared_vm_path Hobo.project_path
    end

    def shared_vm_ip
      maybe(Hobo.user_config.shared_vm.ip) || '10.99.99.99'
    end

    def shared_vm_register_inspector
      ::Hobo::Lib::Vm::Inspector.new(
        :ssh_config_file => Hobo.shared_vm_home + "/shared_vm.ssh_config",
        :project_mount_path => Hobo.shared_vm_project_path,
        :register_as => :shared_vm,
        :path => Hobo.shared_vm_home
      ) unless ::Hobo::Lib::Vm::Inspector.instance :shared_vm
    end

    def shared_vm_shell command, opts = {}
      shared_vm_register_inspector
      opts[:real_command] = command
      opts[:inspector] = :shared_vm
      shell ::Hobo::Lib::Vm::Command.new(command, opts).to_s, opts
    end
  end
end


