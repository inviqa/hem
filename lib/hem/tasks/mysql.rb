desc "MySQL related commands"

namespace :mysql do
  desc "Open a MySQL cli connection"
  option '-D=', '--db=', 'Database'
  task :console do |task|
    opts = { :psuedo_tty => STDIN.tty? }
    opts[:db] = task.opts[:db] if task.opts[:db]

    command = create_mysql_command(opts)
    Hem.logger.debug "mysql:console: #{command}"

    Hem.ui.success "Connecting..." if STDOUT.tty?
    exec command
  end
end
