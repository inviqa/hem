desc "Project asset commands"
project_only
namespace :assets do
  def render_delta delta, type
    if delta[:add] and delta[:add].length > 0
      x = type == 'download' ? 'download from S3' : 'upload to S3'
      Hobo.ui.section "  Files to #{x}:" do
        delta[:add].each do |f|
          Hobo.ui.success "    #{f}"
        end
      end
    end

    if delta[:remove] and delta[:remove].length > 0
      x = type == 'download' ? 'locally' : 'from S3'
      puts Hobo.ui.color "  Files to delete #{x}:", :error
      delta[:remove].each do |f|
        puts Hobo.ui.color "    #{f}", :error
      end
      Hobo.ui.separator
    end
  end

  def do_sync src, dst, env, type
    unless Hobo.project_config.asset_bucket.nil?
      sync = Hobo::Lib::S3::Sync.new(Hobo.aws_credentials)
      changes = sync.sync(src, dst, :dry => true)

      if (changes[:add] + changes[:remove]).length > 0
        answer = if type == 'download' && changes[:remove].length == 0
          'y'
        else
          render_delta changes, type
          Hobo.ui.ask "Proceed? (Y/N)", :default => 'Y'
        end

        if answer.downcase == 'y' 
          sync.sync(src, dst)
        else
          raise Hobo::Error.new "Asset sync aborted"
        end
      else
        Hobo.ui.warning "  No changes required"
      end
    else
      Hobo.ui.warning "  No asset bucket configured. Skipping..."
    end
  end

  desc "Download project assets"
  option "-e=", "--env=", "Environment"
  task :download do |task, args|
    Hobo.ui.section "Synchronizing assets (download)" do
      env = task.opts[:env] || args[:env] || 'development'
      src = "s3://#{Hobo.project_config.asset_bucket}/#{env}/"
      dst = "tools/assets/#{env}"
      do_sync src, dst, env, "download"
    end
  end

  desc "Upload project assets"
  option "-e=", "--env=", "Environment"
  task :upload do |task, args|
    Hobo.ui.section "Synchronizing assets (upload)" do
      env = task.opts[:env] || args[:env] || 'development'
      dst = "s3://#{Hobo.project_config.asset_bucket}/#{env}/"
      src = "tools/assets/#{env}"
      Hobo.ui.warning "Please note that asset uploads can be destructive and will affect the whole team!"
      Hobo.ui.warning "Only upload if you're sure your assets are free from errors and will not impact other team members"
      do_sync src, dst, env, "upload"
    end
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
