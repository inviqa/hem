desc "Project asset commands"
project_only
namespace :assets do

  desc "Download project assets"
  option "-e=", "--env=", "Environment"
  task :download do |task, args|
    Hobo.ui.success "Synchronizing assets (download)"

    unless Hobo.project_config.asset_bucket.nil?
      env = task.opts[:env] || args[:env] || 'development'
      s3_uri = "s3://#{Hobo.project_config.asset_bucket}/#{env}/"
      sync = Hobo::Lib::S3::Sync.new(Hobo.aws_credentials)
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
    Hobo.ui.success "Synchronizing assets (upload)"

    unless Hobo.project_config.asset_bucket.nil?
      env = task.opts[:env] || args[:env] || 'development'
      s3_uri = "s3://#{Hobo.project_config.asset_bucket}/#{env}/"
      sync = Hobo::Lib::S3::Sync.new(Hobo.aws_credentials)
      changes = sync.sync("tools/assets/#{env}", s3_uri)
      Hobo.ui.warning "  No changes required" if (changes[:add] + changes[:remove]).length == 0
    else
      Hobo.ui.warning "  No asset bucket configured. Skipping..."
    end

    Hobo.ui.separator
  end

  desc "Apply project assets"
  option "-e=", "--env=", "Environment"
  project_only
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
