module Hobo
  module Helper

    def vm_shell command, opts = {}
      shell ::Hobo::Lib::Vm::Command.new(command, opts).to_s, opts
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

      ::Hobo::Lib::Vm::Command.new "#{opts[:mysql]} #{opts[:user]} #{opts[:pass]} #{opts[:db]}".strip, opts
    end

    def vm_command command = nil, opts = {}
      ::Hobo::Lib::Vm::Command.new command, opts
    end
  end
end

include Hobo::Helper
