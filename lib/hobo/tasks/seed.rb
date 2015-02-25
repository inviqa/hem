
desc "Project seed commands"
namespace :seed do

  desc "Create a new project from a seed repository"

  option '-g=', '--git-url=', 'Git repository for project'
  option '-s=', '--seed=', 'Seed name or URL to use'
  option '-b=', '--branch=', 'Seed branch to use'
  option '-d=', '--data=', 'Seed data to save to the project hobo configuration', :as => Hash

  task :plant, [ :name ] do |t, args|
    name = args[:name]

    Hobo.project_path = File.join(Dir.pwd, name)

    raise Hobo::UserError.new "Name must match sprint zero guidelines" unless name.match /[a-z0-9\-]+/
    raise Hobo::UserError.new "#{Hobo.project_path} already exists!" if File.exists? Hobo.project_path

    config = {
      :name => name,
      :project_path => Hobo.project_path,
      :git_url => t.opts[:'git-url'] || Hobo.ui.ask("Repository URL", default: "git@github.com:inviqa/#{name}"),
      :ref => t.opts[:branch] || 'master' 
    }

    seed_options = %w( default magento symfony custom )

    seed_name = t.opts[:seed] || Hobo.ui.ask_choice('Project seed', seed_options, default: 'default')
    use_short_seed_name = true

    if seed_name == 'custom'
      seed_name = Hobo.ui.ask('Please enter a git url or a path to a local git checkout containing the seed')
      use_short_seed_name = false
    end

    config[:seed] = {
      :name => File.basename(seed_name, '.git'),
      :url => Hobo::Lib::Seed::Seed.name_to_url(seed_name, :use_short_seed_name => use_short_seed_name)
    }

    unless t.opts[:data].nil?
      data = t.opts[:data].inject({}){|hash,(k,v)| hash[k.to_sym] = v; hash}
      config.merge!(data)
    end

    seed = Hobo::Lib::Seed::Seed.new(
      File.join(Hobo.seed_cache_path, config[:seed][:name]),
      config[:seed][:url]
    )

    config[:vm_ip] = seed.vm_ip

    Hobo::Lib::Seed::Project.new().setup(seed, config)

    Hobo.ui.separator
    Hobo.ui.success "Your new project is available in #{Hobo.project_path}."
    Hobo.ui.success "You will need to review the initial commit and if all is well, push the repository to github using `git push origin --all`."
    Hobo.ui.separator
  end
end
