namespace :host do
  task :config do
    config = Hobo.user_config

    config.full_name = Hobo.ui.ask "Full name", :default => config.full_name
    config.email = Hobo.ui.ask "Email", :default => config.email

    config.aws = {}
    config.aws.access_key_id = Hobo.ui.ask "AWS access key ID", :default => config.aws.access_key_id
    config.aws.secret_access_key = Hobo.ui.ask "AWS secret access key", :default => config.aws.secret_access_key

    Hobo::Config::File.save(Hobo.user_config_file, config)
    File.chmod(0600, Hobo.user_config_file)
  end

  task :check do
    Hobo::HostCheck.check false
  end
end