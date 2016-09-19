
desc "Project seed commands"
namespace :seed do

  desc "Create a new project from a seed repository"

  option '-g=', '--git-url=', 'Git repository for project'
  option '-s=', '--seed=', 'Seed name or URL to use'
  option '-b=', '--branch=', 'Seed branch to use'
  option '-d=', '--data=', 'Seed data to save to the project hem configuration', :as => Hash

  argument 'name'

  task :plant do |t, args|
    name = args[:name]

    Hem.project_path = File.join(Dir.pwd, name)

    raise Hem::UserError.new "Name must match sprint zero guidelines" unless name.match /[a-z0-9\-]+/
    raise Hem::UserError.new "#{Hem.project_path} already exists!" if File.exists? Hem.project_path

    config = {
      :name => name,
      :project_path => Hem.project_path,
      :git_url => t.opts[:'git-url'] || Hem.ui.ask("Repository URL", default: "git@github.com:inviqa/#{name}"),
      :ref => t.opts[:branch] || 'master'
    }

    seed_options = %w( default ezplatform magento1 magento2 spryker symfony drupal8 plugin custom )

    seed_name = t.opts[:seed] || Hem.ui.ask_choice('Project seed', seed_options, default: 'default')
    use_short_seed_name = true

    if seed_name == 'custom'
      seed_name = Hem.ui.ask('Please enter a git url or a path to a local git checkout containing the seed')
      use_short_seed_name = false
    end

    config[:seed] = {
      :name => File.basename(seed_name, '.git'),
      :url => Hem::Lib::Seed::Seed.name_to_url(seed_name, :use_short_seed_name => use_short_seed_name)
    }

    unless t.opts[:data].nil?
      data = t.opts[:data].inject({}){|hash,(k,v)| hash[k.to_sym] = v; hash}
      config.merge!(data)
    end

    seed = Hem::Lib::Seed::Seed.new(
      File.join(Hem.seed_cache_path, config[:seed][:name]),
      config[:seed][:url]
    )

    config[:vm_ip] = seed.vm_ip

    Hem::Lib::Seed::Project.new().setup(seed, config)

    Hem.ui.separator
    Hem.ui.success "Your new project is available in #{Hem.project_path}."
    Hem.ui.success "You will need to review the initial commit and if all is well, push the repository to github using `git push origin --all`."
    Hem.ui.separator
  end
end
