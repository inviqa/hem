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
        shell "php", File.join(Hobo.project_bin_path, 'composer.phar'), "install", "--ansi", realtime: true, indent: 2
      end
    end
    Hobo.ui.separator
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
  task :chef do
    locate "*Cheffile" do
      Hobo.ui.title "Installing chef dependencies"
      Bundler.with_clean_env do
        bundle_shell "librarian-chef", "install", "--verbose", realtime: true, indent: 2 do |line|
          line =~ /Installing.*</ ? line : nil
        end
      end
      Hobo.ui.separator
    end
  end
end