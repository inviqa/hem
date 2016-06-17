module Hem
  module Helper
    def get_run_environment
      [
        ENV['HEM_RUN_ENV'],
        Hem.project_config.run_environment,
        Hem.user_config.run_environment,
        'vm'
      ].each do |env|
        return env unless env.nil?
      end
    end

    def run command, opts = {}
      create_command(command, opts).run
    end
    alias_method :run_command, :run

    def create_mysql_command opts = {}
      opts = {
        :auto_echo => true,
        :db => "",
        :user => maybe(Hem.project_config.mysql.username) || "",
        :pass => maybe(Hem.project_config.mysql.password) || "",
        :mysql => 'mysql'
      }.merge(opts)

      opts[:user] = "-u#{opts[:user].shellescape}" unless opts[:user].empty?
      opts[:pass] = "-p#{opts[:pass].shellescape}" unless opts[:pass].empty?
      opts[:db] = opts[:db].shellescape unless opts[:db].empty?

      create_command "#{opts[:mysql]} #{opts[:user]} #{opts[:pass]} #{opts[:db]}".strip, opts
    end

    def create_command command = nil, opts = {}
      run_env = opts[:run_environment] || get_run_environment
      case run_env
      when 'vm'
        ::Hem::Lib::Vm::Command.new command, opts
      when 'local'
        ::Hem::Lib::Local::Command.new command, opts
      else
        raise Hem::InvalidCommandOrOpt.new "run_environment #{run_env}"
      end
    end
  end
end

self.extend Hem::Helper
