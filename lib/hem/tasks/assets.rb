desc "Project asset commands"
project_only
namespace :assets do
  def render_delta delta, type
    if delta[:add] and delta[:add].length > 0
      x = type == 'download' ? 'download from S3' : 'upload to S3'
      Hem.ui.section "  Files to #{x}:" do
        delta[:add].each do |f|
          Hem.ui.success "    #{f}"
        end
      end
    end

    if delta[:remove] and delta[:remove].length > 0
      x = type == 'download' ? 'locally' : 'from S3'
      puts Hem.ui.color "  Files to delete #{x}:", :error
      delta[:remove].each do |f|
        puts Hem.ui.color "    #{f}", :error
      end
      Hem.ui.separator
    end
  end

  def do_sync src, dst, env, type
    unless Hem.project_config.asset_bucket.nil?
      sync = Hem::Lib::S3::Sync.new(Hem.aws_credentials)
      changes = sync.sync(src, dst, :dry => true)

      if (changes[:add] + changes[:remove]).length > 0
        answer = if type == 'download' && changes[:remove].length == 0
          'y'
        else
          render_delta changes, type
          Hem.ui.ask "Proceed? (Y/N)", :default => 'Y'
        end

        if answer.downcase == 'y'
          sync.sync(src, dst)
        else
          raise Hem::Error.new "Asset sync aborted"
        end
      else
        Hem.ui.warning "  No changes required"
      end
    else
      Hem.ui.warning "  No asset bucket configured. Skipping..."
    end
  end

  desc "Download project assets"
  option "-e=", "--env=", "Environment"
  task :download do |task, args|
    Hem.ui.section "Synchronizing assets (download)" do
      env = task.opts[:env] || args[:env] || 'development'
      src = "s3://#{Hem.project_config.asset_bucket}/#{env}/"
      dst = "#{Hem.project_path}/tools/assets/#{env}"
      do_sync src, dst, env, "download"
    end
  end

  desc "Upload project assets"
  option "-e=", "--env=", "Environment"
  task :upload do |task, args|
    Hem.ui.section "Synchronizing assets (upload)" do
      env = task.opts[:env] || args[:env] || 'development'
      dst = "s3://#{Hem.project_config.asset_bucket}/#{env}/"
      src = "#{Hem.project_path}/tools/assets/#{env}"
      Hem.ui.warning "Please note that asset uploads can be destructive and will affect the whole team!"
      Hem.ui.warning "Only upload if you're sure your assets are free from errors and will not impact other team members"
      do_sync src, dst, env, "upload"
    end
  end

  desc "Apply project assets"
  option "-a=", "--applicator=", "Asset applicator to apply, default all"
  option "-e=", "--env=", "Environment"
  option "-f", "--force", "Force application of already applied assets"
  project_only
  task :apply do |task, args|
    env = task.opts[:env] || args[:env] || 'development'
    path = "tools/assets/#{env}"
    opts = {
      force: task.opts[:force] || args[:force] || false
    }

    applicator_name = task.opts[:applicator] || args[:applicator]
    case applicator_name
    when nil, 'all'
      asset_applicators = Hem.asset_applicators
    else
      asset_applicators = Hem.asset_applicators.select do |applicator|
        applicator.name == applicator_name
      end
    end

    next unless File.exists? path

    Dir.new(path).each do |file|
      file = File.join(path, file)
      next unless File.file? file
      asset_applicators.each do |applicator|
        applicator.call(file, opts) if applicator.matches?(file)
      end
    end
  end
end
