desc "VM related commands"
project_only
namespace :vm do
  def vagrantfile &block
    locate "*Vagrantfile" do
      yield
    end
  end

  def vagrant_exec *args
    opts = { :realtime => true, :indent => 2 }
    color = Hobo.ui.supports_color? ? '--color' : '--no-color'

    if Hobo.windows?
      opts[:env] = { 'VAGRANT_HOME' => windows_short(dir) } if ENV['HOME'].match(/\s+/) && !ENV['VAGRANT_HOME']
    end

    args.unshift 'vagrant'
    args.push color
    args.push opts

    shell *args
  end

  def windows_short dir
    segments = dir.gsub(/\\/, '/').split('/')
    segments.map do |segment|
      if segment.match /\s+/
        # This may fail in some edge cases but better than naught
        # See the following link for the correct solution
        # http://stackoverflow.com/questions/10224572/convert-long-filename-to-short-filename-8-3
        segment.upcase.gsub(/\s+/, '')[0...6] + '~1'
      else
        segment
      end
    end.join('/')
  end

  desc "Start & provision VM"
  task :up => [ 'assets:download', 'vm:start', 'vm:provision', 'deps:composer', 'assets:apply' ]

  desc "Stop VM"
  task :stop do
    vagrantfile do
      Hobo.ui.title "Stopping VM"
      vagrant_exec 'suspend'
      Hobo.ui.separator
    end
  end

  desc "Rebuild VM"
  task :rebuild => [ 'vm:destroy', 'vm:up' ]

  desc "Destroy VM"
  task :destroy do
    vagrantfile do
      Hobo.ui.title "Destroying VM"
      vagrant_exec 'destroy', '--force'
      Hobo.ui.separator
    end
  end

  desc "Start VM without provision"
  task :start => [ "deps:gems", "deps:chef", "deps:vagrant_plugins" ] do
    vagrantfile do
      Hobo.ui.title "Starting vagrant VM"
      vagrant_exec 'up', '--no-provision'
      Hobo.ui.separator
    end
  end

  desc "Provision VM"
  task :provision => [ "deps:chef" ] do
     vagrantfile do
      Hobo.ui.title "Provisioning VM"
      vagrant_exec 'provision'
      Hobo.ui.separator
    end
  end

  desc "Open an SSH connection"
  task :ssh do |task|
    execute = task.opts[:_unparsed]
    opts = { :psuedo_tty => STDIN.tty? }

    Hobo.ui.success "Determining VM connection details..." if STDOUT.tty?
    command = execute.empty? ? vm_command(nil, opts) : vm_command(execute, opts)
    Hobo.logger.debug "vm:ssh: #{command}"

    Hobo.ui.success "Connecting..." if STDOUT.tty?
    exec command
  end

  desc "Open a MySQL cli connection"
  option '-D=', '--db=', 'Database'
  task :mysql do |task|
    opts = { :psuedo_tty => STDIN.tty? }
    opts[:db] = task.opts[:db] if task.opts[:db]

    Hobo.ui.success "Determining VM connection details..." if STDOUT.tty?
    command = vm_mysql(opts)
    Hobo.logger.debug "vm:mysql: #{command}"

    Hobo.ui.success "Connecting..." if STDOUT.tty?
    exec command
  end

  desc "Open a Redis cli connection"
  task :redis do
    opts = { :psuedo_tty => STDIN.tty? }

    Hobo.ui.success "Determining VM connection details..." if STDOUT.tty?
    command = vm_command("redis-cli", opts)
    Hobo.logger.debug "vm:redis: #{command}"

    Hobo.ui.success "Connecting..." if STDOUT.tty?
    exec command
  end
end
