require 'hobo/lib/s3sync'

desc "Project asset commands"
project_only
namespace :assets do

  desc "Download project assets"
  option "-e=", "--env=", "Environment"
  task :download do |task, args|
    Hobo.ui.success "Synchonizing assets (download)"

    unless Hobo.project_config.asset_bucket.nil?
      env = task.opts[:env] || args[:env] || 'development'
      s3_uri = "s3://#{Hobo.project_config.asset_bucket}/#{env}/"

      sync = Hobo::Lib::S3Sync.new(
        maybe(Hobo.user_config.aws.access_key_id),
        maybe(Hobo.user_config.aws.secret_access_key)
      )

      changes = sync.sync(s3_uri, "tools/assets/#{env}")
      Hobo.ui.warning "  No changes required" if (changes[:add] + changes[:remove]).length == 0
    else
      Hobo.ui.warning "  No asset bucket configured. Skipping..."
    end
    Hobo.ui.separator
  end

  desc "Upload project assets"
  option "-e=", "--env=", "Environment"
  task :upload do |task, args|

    Hobo.ui.success "Synchronzing assets (upload)"

    unless Hobo.project_config.asset_bucket.nil?
      env = task.opts[:env] || args[:env] || 'development'
      s3_uri = "s3://#{Hobo.project_config.asset_bucket}/#{env}/"

      sync = Hobo::Lib::S3Sync.new(
        maybe(Hobo.user_config.aws.access_key_id),
        maybe(Hobo.user_config.aws.secret_access_key)
      )

      changes = sync.sync("tools/assets/#{env}", s3_uri)
      Hobo.ui.warning "  No changes required" if (changes[:add] + changes[:remove]).length == 0
    else
      Hobo.ui.warning "  No asset bucket configured. Skipping..."
    end

    Hobo.ui.separator
  end

  desc "Apply project assets"
  option "-e=", "--env=", "Environment"
  task :apply do |task, args|
    env = task.opts[:env] || args[:env] || 'development'
    path = "tools/assets/#{env}"

    next unless File.exists? path

    Dir.new(path).each do |file|
      file = File.join(path, file)
      next unless File.file? file
      Hobo.asset_applicators.each do |matcher, proc|
        proc.call(file) if matcher.match(file)
      end
    end

  end
end

# Built in applicators
Hobo.asset_applicators.register /.*\.files\.(tgz|tar\.gz|tar\.bz2)/ do |file|
  Hobo.ui.title "Applying file dump (#{file})"
  Dir.chdir Hobo.project_path do
    shell "tar -xvf #{file.shellescape}"
  end
end

Hobo.asset_applicators.register /.*\.sql\.gz/ do |file|
  matches = file.match(/^([^\.]+).*\.sql\.gz/)
  db = matches[1]

  begin
    shell(vm_mysql << "USE #{db}")
    Hobo.ui.warning "Already applied (#{file})"
    next
  rescue Hobo::ExternalCommandError => e
    raise e if e.exit_code != 1
  end

  Hobo.ui.title "Applying mysqldump (#{file})"

  shell(vm_mysql << "CREATE DATABASE #{db}")
  shell(vm_mysql(:auto_echo => false, :db => db) << "zcat #{file.shellescape}")
end