desc "Configure hem"
task :config do
  config = Hem.user_config

  # Not required at present
  # config.full_name = Hem.ui.ask("Full name", :default => config.full_name).to_s
  # config.email = Hem.ui.ask("Email", :default => config.email).to_s

  config[:aws] ||= {}
  config.aws.access_key_id = Hem.ui.ask("AWS access key ID", :default => config.aws.access_key_id).to_s
  config.aws.secret_access_key = Hem.ui.ask("AWS secret access key", :default => config.aws.secret_access_key).to_s

  Hem::Config::File.save(Hem.user_config_file, config)
  File.chmod(0600, Hem.user_config_file)
end
