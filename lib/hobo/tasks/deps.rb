require 'bundler'

desc "Dependency related tasks"
hidden true
namespace :deps do

  desc "Install Gem dependencies"
  task :gems do
    locate "*Gemfile" do
      Hobo.ui.title "Installing Gem dependencies"
      Bundler.with_clean_env do
        shell "bundle", "install", realtime: true, indent: 2
      end
      Hobo.ui.separator
    end
  end

  desc "Install composer dependencies"
  task :composer do
    if File.exists? File.join(Hobo.project_path, "composer.json")
      Rake::Task["tools:composer"].invoke
      Hobo.ui.title "Installing composer dependencies"
      Dir.chdir Hobo.project_path do
        ansi = Hobo.ui.supports_color? ? '--ansi' : ''
        args = [ "php bin/composer.phar install #{ansi} --prefer-dist", { realtime: true, indent: 2 } ]
        complete = false

        check = Hobo::Lib::HostCheck.check(:filter => /php_present/)

        if check[:php_present] == :ok
          begin
            shell *args
            complete = true
          rescue Hobo::ExternalCommandError
            Hobo.ui.warning "Installing composer dependencies locally failed!"
          end
        end

        if !complete
          vm_shell *args
        end

        Hobo.ui.success "Composer dependencies installed"
      end

      Hobo.ui.separator
    end
  end

  desc "Install vagrant plugins"
  task :vagrant_plugins => [ "deps:gems" ] do
    plugins = shell "vagrant plugin list", :capture => true
    locate "*Vagrantfile" do
      File.read("Vagrantfile").split("\n").each do |line|
        next unless line.match /Vagrant\.require_plugin (.*)/
        plugin = $1.gsub(/['"]*/, '')
        next if plugins.include? "#{plugin} "
        Hobo.ui.title "Installing vagrant plugin: #{plugin}"
        bundle_shell "vagrant", "plugin", "install", plugin, :realtime => true, :indent => 2
        Hobo.ui.separator
      end
    end
  end

  desc "Install chef dependencies"
  task :chef => [ "deps:gems" ] do
    locate "*Cheffile" do
      Hobo.ui.title "Installing chef dependencies"
      Bundler.with_clean_env do
        bundle_shell "librarian-chef", "install", "--verbose", realtime: true, indent: 2 do |line|
          line =~ /Installing.*</ ? line.strip + "\n" : nil
        end
      end
      Hobo.ui.separator
    end
  end
end
