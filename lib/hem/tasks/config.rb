desc "Configure hobo"
task :config do
  config = Hobo.user_config

  # Not required at present
  # config.full_name = Hobo.ui.ask("Full name", :default => config.full_name).to_s
  # config.email = Hobo.ui.ask("Email", :default => config.email).to_s

  config[:aws] ||= {}
  config.aws.access_key_id = Hobo.ui.ask("AWS access key ID", :default => config.aws.access_key_id).to_s
  config.aws.secret_access_key = Hobo.ui.ask("AWS secret access key", :default => config.aws.secret_access_key).to_s

  Hobo::Config::File.save(Hobo.user_config_file, config)
  File.chmod(0600, Hobo.user_config_file)
end
