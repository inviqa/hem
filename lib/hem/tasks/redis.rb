desc "Redis related commands"
namespace :redis do
  desc "Open a Redis cli connection"
  task :cli do
    opts = { :psuedo_tty => STDIN.tty? }

    command = create_command("redis-cli", opts)
    Hem.logger.debug "redis:cli: #{command}"

    Hem.ui.success "Connecting..." if STDOUT.tty?
    exec command
  end

  desc "Flush some or all redis dbs"
  argument :dbs, optional: true, default: {}, as: Array
  task :flush do |task, args|
    if args[:dbs].empty?
      run 'redis-cli FLUSHALL'
    else
      args[:dbs].each do |db|
        Hem.ui.success "Flushing redis db #{db}" if STDOUT.tty?
        shell create_command('redis-cli', auto_echo: true).pipe("SELECT #{db}\nFLUSHDB\n")
      end
    end
  end
end
