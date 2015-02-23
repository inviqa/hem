module Hobo
  module Helper
    module SharedVm
      def shared_vm_started?
        Hobo.shared_vm_register_inspector
        ::Hobo::Lib::Vm::Inspector.instance(:shared_vm).started?
      end

      def shared_vm_command command, opts = {}
        Hobo.shared_vm_register_inspector
        opts[:real_command] = command
        opts[:inspector] = :shared_vm
        if opts[:container]
          pod, container  = opts[:container].split(':')
          container_id = shared_vm_lookup_container_id(
            Hobo.project_config.shared_vm_tag,
            pod,
            container
          )

          container_pwd = nil

          # Super hacky fudgy tastic pwd rewrites for compatibility with vm_shell pwds in containers
          if opts[:pwd]
            binds = shared_vm_shell(
              "docker inspect -f '{{range .HostConfig.Binds}}{{.}},{{end}}' #{container_id}",
              :capture => true
            ).split(',').reject(&:empty?)

            binds.each do |bind|
              host_path, container_path = bind.split(':')
              container_pwd = container_path if opts[:pwd] =~ /^#{host_path}/
              break if container_pwd
            end
          end

          opts[:pwd] = nil if container_pwd

          # More super hacky fudgy tastic logic for vm_shell compat
          command = "#{command}#{opts[:append]}"
          opts[:append] = ''

          cmd = Proc.new do |runtime_opts|
            require 'shellwords'
            interactive = '-i' if runtime_opts[:pipe] || runtime_opts[:pipe_in_vm]
            container_pwd = "cd #{container_pwd} && " if container_pwd
            "docker exec #{interactive} #{container_id} bash -c \"#{container_pwd}#{command}\""
          end
        end
        ::Hobo::Lib::Vm::Command.new(cmd || command, opts)
      end

      def shared_vm_shell command, opts = {}
        shell shared_vm_command(command, opts).to_s, opts
      end

      def shared_vm_mysql opts = {}
        opts = {
          :auto_echo => true,
          :db => "",
          :user => maybe(Hobo.project_config.mysql.username) || "",
          :pass => maybe(Hobo.project_config.mysql.password) || "",
          :container => 'mysql:mysql' # HACK; this assumes a pod called mysql with a container called mysql
        }.merge(opts)

        mysql = opts[:mysql] || 'mysql'
        user = "-u#{opts[:user].shellescape}" unless opts[:user].empty?
        pass = "-p#{opts[:pass].shellescape}" unless opts[:pass].empty?
        db = opts[:db].shellescape unless opts[:db].empty?

        shared_vm_command [ mysql, user, pass, db ].compact.join(' '), opts
      end

      def shared_vm_wait_for_pod project, pod_name
        require 'json'

        (0..60).to_a.each do
          uri = URI("http://#{Hobo.shared_vm_ip}:8080/api/v1beta1/pods/?namespace=#{project}&labels=name=#{pod_name}")
          pods = JSON.parse(Net::HTTP.get(uri))

          pod = pods['items'].first
          info = pod['currentState']['info']

          return pod if info && info['net']
          sleep 1
        end

        return
      end

      def shared_vm_lookup_container_id project, pod_name, container = nil
        pod = shared_vm_wait_for_pod(project, pod_name)

        # Now we narrow down the specific container id to "connect" to
        container_info = pod['currentState']['info']
        container_info.delete 'net'

        results = Hash[container_info.map do |k,v|
          [k, v['containerID'].gsub(/^docker:\/\//, '')]
        end]

        return results[container] if container
        return results
      end
    end
  end
end

include Hobo::Helper::SharedVm
