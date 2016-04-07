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
end
