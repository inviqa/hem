
desc "Project seed commands"
namespace :seed do

  desc "Create a new project from a seed repository"

  option '-g=', '--git-url=', 'Git repository for project'
  option '-s=', '--seed=', 'Seed name or URL to use'

  task :plant, [ :name ] do |t, args|
    name = args[:name]

    Hobo.project_path = File.join(Dir.pwd, name)

    raise Hobo::UserError.new "Name must match sprint zero guidelines" unless name.match /[a-z0-9\-]+/
    raise Hobo::UserError.new "#{Hobo.project_path} already exists!" if File.exists? Hobo.project_path

    config = {
      :name => name,
      :project_path => Hobo.project_path,
      :git_url => t.opts[:'git-url'] || Hobo.ui.ask("Repository URL", default: "git@github.com:inviqa/#{name}")
    }

    seed_name = t.opts[:seed] || Hobo.ui.ask("Project seed", default: "default")

    config[:seed] = {
      :name => File.basename(seed_name),
      :url => Hobo::Lib::Seed::Seed.name_to_url(seed_name)
    }

    seed = Hobo::Lib::Seed::Seed.new(
      File.join(Hobo.seed_cache_path, config[:seed][:name]),
      config[:seed][:url]
    )

    Hobo::Lib::Seed::Project.new().setup(seed, config)

    Hobo.ui.separator
    Hobo.ui.success "Your new project is available in #{Hobo.project_path}.\n"
    Hobo.ui.success "You will need to review the initial commit and if all is well, push the repository to github using `git push origin --all`."
    Hobo.ui.separator
  end
end