module Hem
  module Helper
    def vm_shell command, opts = {}
      Hem.ui.warning "Using vm_shell is deprecated and will be removed in a future release. Please use run_command instead"
      opts['run_environment'] = 'vm'
      run_command command, opts
    end

    def vm_mysql opts = {}
      Hem.ui.warning "Using vm_mysql is deprecated and will be removed in a future release. Please use create_mysql_command instead"
      opts['run_environment'] = 'vm'
      create_mysql_command opts
    end

    def vm_command command = nil, opts = {}
      Hem.ui.warning "Using vm_command is deprecated and will be removed in a future release. Please use create_command instead"
      opts['run_environment'] = 'vm'
      create_command command, opts
    end
  end
end

include Hem::Helper
