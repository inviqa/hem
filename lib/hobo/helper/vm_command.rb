require 'hobo/helper/shell'

module Hobo
  module Helper
    def vm_shell command, opts = {}
      shell VmCommand.new(command).to_s, opts
    end

    def vm_mysql opts = {}
      opts = {
        :auto_echo => true,
        :db => "",
        :user => maybe(Hobo.project_config.mysql.username) || "root",
        :pass => maybe(Hobo.project_config.mysql.password) || "root"
      }.merge(opts)

      VmCommand.new "mysql -u#{opts[:user].shellescape} -p#{opts[:pass].shellescape} #{opts[:db].shellescape}", opts
    end

    def vm_command command = nil, opts = {}
      VmCommand.new command, opts
    end

    private

    class VmCommand
      attr_accessor :opts, :command

      def initialize command, opts = {}
        @command = command
        @opts = {
          :auto_echo => false,
          :psuedo_tty => true,
          :ssh_identity => "#{ENV['HOME'].shellescape}/.vagrant.d/insecure_private_key",
          :ssh_user => "vagrant",
          :ssh_host => maybe(Hobo.project_config.hostname) || ""
        }.merge(opts)
      end

      def << pipe
        pipe = "echo #{pipe.shellescape}" if opts[:auto_echo]
        @pipe = pipe
        @opts[:psuedo_tty] = false
        return self
      end

      def to_s
        psuedo_tty = @opts[:psuedo_tty] ? "-t" : ""
        command = [
          "ssh -i #{opts[:ssh_identity]} #{psuedo_tty} #{opts[:ssh_user].shellescape}@#{opts[:ssh_host].shellescape}",
          @command
        ].compact.join(" -- ")

        [
          @pipe,
          command
        ].compact.join(" | ")
      end

      def to_str
        to_s
      end
    end
  end
end

include Hobo::Helper