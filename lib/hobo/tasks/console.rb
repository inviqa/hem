desc "VM console shortcut commands"
project_only
namespace :console do
  desc "Open an SSH connection"
  task :ssh do
    exec vm_command
  end

  desc "Open a MySQL cli connection"
  task :mysql do
    exec vm_mysql
  end

  desc "Open a Redis cli connection"
  task :redis do
    exec vm_command "redis-cli"
  end
end
