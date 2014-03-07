require 'tempfile'
require 'net/ssh/simple'

module Hobo
  module Helper
    attr_accessor :vm_project_mount_path

    # Really expensive method to auto-detect where root project mount exists in VM.
    # It assumes that the project root is directly mounted.
    # We cache it in configuration once we find it so it only has to happen once.
    def vm_project_mount_path
      configured_path = maybe(Hobo.project_config.vm.project_mount_path)
      return configured_path if configured_path
      return @vm_project_mount_path if @vm_project_mount_path

      tmp = Tempfile.new('vm_command_locator', Hobo.project_path)
      tmp.write(Hobo.project_path)

      locator_file = File.basename(tmp.path)

      pattern = OS.windows? ? 'vboxsf' : Hobo.project_path.shellescape

      # TODO genericise the command escaping from lib/hobo/patches/slop.rb to avoid nested shell escaping hell
      sed = 's/.* on \(.*\) type.*/\\\1\\\/%%/g'.gsub('%%', locator_file)
      locator_results = vm_shell(
        "mount | grep #{pattern} | sed -e\"#{sed}\" | xargs md5sum",
        :capture => true,
        :pwd => '/',
        :psuedo_tty => false,
        :ignore_errors => true
      )

      tmp.close

      match = locator_results.match(/^([a-z0-9]{32})\s+(.*)$/)

      raise Exception.new("Unable to locate project mount point in VM") if !match

      @vm_project_mount_path = File.dirname(match[2])

      # Stash it in config
      Hobo.project_config[:vm] ||= {}
      Hobo.project_config[:vm][:project_mount_path] = @vm_project_mount_path
      Hobo::Config::File.save(Hobo.project_config_file, Hobo.project_config)

      return @vm_project_mount_path
    end

    def vm_shell command, opts = {}
      shell VmCommand.new(command, opts).to_s, opts
    end

    def vm_mysql opts = {}
      opts = {
        :auto_echo => true,
        :db => "",
        :user => maybe(Hobo.project_config.mysql.username) || "",
        :pass => maybe(Hobo.project_config.mysql.password) || "",
        :mysql => 'mysql'
      }.merge(opts)

      opts[:user] = "-u#{opts[:user].shellescape}" unless opts[:user].empty?
      opts[:pass] = "-p#{opts[:pass].shellescape}" unless opts[:pass].empty?
      opts[:db] = opts[:db].shellescape unless opts[:db].empty?

      VmCommand.new "#{opts[:mysql]} #{opts[:user]} #{opts[:pass]} #{opts[:db]}".strip, opts
    end

    def vm_command command = nil, opts = {}
      VmCommand.new command, opts
    end

    private

    class VmInspector
      attr_accessor :ssh_config, :project_mount_path

      def project_mount_path
        #configured_path = maybe(Hobo.project_config.vm.project_mount_path)
        #return configured_path if configured_path
        #return @project_mount_path if @project_mount_path

        tmp = Tempfile.new('vm_command_locator', Hobo.project_path)

        begin
          tmp.write(Hobo.project_path)

          locator_file = File.basename(tmp.path)

          pattern = OS.windows? ? 'vboxsf' : Hobo.project_path.shellescape

          sed = 's/.* on \(.*\) type.*/\1\/%%/g'.gsub('%%', locator_file)
          locator_results = VmCommand.new(
            "mount | grep #{pattern} | sed -e\"#{sed}\" | xargs md5sum",
            :capture => true,
            :pwd => '/'
          ).run
        ensure
          tmp.unlink
        end

        match = locator_results.match(/^([a-z0-9]{32})\s+(.*)$/)

        raise Exception.new("Unable to locate project mount point in VM") if !match

        @vm_project_mount_path = File.dirname(match[2])

        # Stash it in config
        Hobo.project_config[:vm] ||= {}
        Hobo.project_config[:vm][:project_mount_path] = @vm_project_mount_path
        Hobo::Config::File.save(Hobo.project_config_file, Hobo.project_config)

        return @vm_project_mount_path
      end

      def ssh_config
        return @ssh_config if @ssh_config
        config = nil
        locate "*Vagrantfile" do
          config = bundle_shell "vagrant ssh-config", :capture => true
        end

        raise Exception.new "Could not retrieve VM ssh configuration" unless config

        patterns = {
          :ssh_user => /^\s*User (.*)$/,
          :ssh_identity => /^\s*IdentityFile (.*)$/,
          :ssh_host => /^\s*HostName (.*)$/,
          :ssh_port => /^\s*Port (\d+)/
        }

        output = {}

        patterns.each do |k, pattern|
          match = config.match(pattern)
          output[k] = match[1] if match
        end

        return @ssh_config = output
      end
    end

    class VmCommand
      class << self
        attr_accessor :vm_inspector
        @@vm_inspector = VmInspector.new
      end

      attr_accessor :opts, :command

      def initialize command, opts = {}
        @command = command
        @opts = {
          :auto_echo => false,
          :psuedo_tty => false,
          :pwd => opts[:pwd] || @@vm_inspector.project_mount_path,
          :append => ''
        }.merge(opts)
      end

      def << pipe
        pipe = "echo #{pipe.shellescape}" if opts[:auto_echo]
        @pipe = pipe
        @opts[:psuedo_tty] = false
        return self
      end

      def < pipe
        pipe = "echo '#{pipe.shellescape}'" if opts[:auto_echo]
        @pipe_in_vm = pipe
        @opts[:psuedo_tty] = false
        return self
      end

      # TODO Refactor in to ssh helper with similar opts to shell helper
      # TODO Migrate all vm_shell functionality this direction
      def run
        return if @command.nil?
        opts = @@vm_inspector.ssh_config.merge(@opts)

        Net::SSH::Simple.sync do
          ssh_opts = {
            :user => opts[:ssh_user],
            :port => opts[:ssh_port],
            :forward_agent => true,
            :global_known_hosts_file => "/dev/null",
            :paranoid => false,
            :user_known_hosts_file => "/dev/null"
          }

          ssh_opts[:keys] = [opts[:ssh_identity]] if opts[:ssh_identity]

          tmp = Tempfile.new "vm_command_exec"

          begin
            filename = File.basename(tmp.path)
            remote_file = "/tmp/#{filename}"
            tmp.write "#{@command}#{opts[:append]}"
            tmp.close

            scp_put opts[:ssh_host], tmp.path, remote_file, ssh_opts
            result = ssh opts[:ssh_host], "cd #{opts[:pwd]}; exec /bin/bash #{remote_file}", ssh_opts
            ssh opts[:ssh_host], "rm #{remote_file}", ssh_opts

            # Throw exception if exit code not 0

            return opts[:capture] ? result.stdout : result.success
          ensure
            tmp.unlink
          end
        end
      end

      # TODO Speed up Vagrant SSH connections
      # May need to be disabled for windows (mm_send_fd: UsePrivilegeSeparation=yes not supported)
      # https://gist.github.com/jedi4ever/5657094

      def to_s
        opts = @@vm_inspector.ssh_config.merge(@opts)

        psuedo_tty = opts[:psuedo_tty] ? "-t" : ""

        ssh_command = [
          "ssh",
          "-o 'UserKnownHostsFile /dev/null'",
          "-o 'StrictHostKeyChecking no'",
          "-o 'ForwardAgent yes'",
          "-o 'LogLevel FATAL'",
          "-p #{opts[:ssh_port]}",
          "-i #{opts[:ssh_identity].shellescape}",
          psuedo_tty,
          "#{opts[:ssh_user].shellescape}@#{opts[:ssh_host].shellescape}"
        ].join(" ")

        pwd_set_command = " -- \"cd #{@opts[:pwd].shellescape}; exec /bin/bash"

        vm_command = [
          @pipe_in_vm,
          @command
        ].compact.join(" | ")

        command = [
          ssh_command + pwd_set_command,
          vm_command.empty? ? nil : vm_command.shellescape
        ].compact.join(" -c ") + "#{opts[:append].shellescape}\""

        [
          @pipe,
          command
        ].compact.join(" | ")
      end

      def to_str
        to_s
      end

      private

      def vagrant_config
        return @@vagrant_config if @@vagrant_config
        config = nil
        locate "*Vagrantfile" do
          config = bundle_shell "vagrant ssh-config", :capture => true
        end

        raise Exception.new "Could not retrieve VM ssh configuration" unless config

        patterns = {
          :ssh_user => /^\s+User (.*)$/,
          :ssh_identity => /^\s+IdentityFile (.*)$/,
          :ssh_host => /^\s+HostName (.*)$/,
          :ssh_port => /^\s+Port (\d+)/
        }

        output = {}

        patterns.each do |k, pattern|
          match = config.match(pattern)
          output[k] = match[1]
        end

        return @@vagrant_config = output
      end
    end
  end
end

include Hobo::Helper
