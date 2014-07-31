desc "Dependency related tasks"
hidden true
namespace :deps do

  desc "Install Gem dependencies"
  task :gems do
    locate "*Gemfile" do
      required = shell("bundle", "check", :exit_status => true) != 0
      if required
        Hobo.ui.title "Installing Gem dependencies"
        shell "bundle", "install", realtime: true, indent: 2
        Hobo.ui.separator
      end
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

        if maybe(Hobo.project_config.tasks.deps.composer.disable_host_run)
          check = Hobo::Lib::HostCheck.check(:filter => /php_present/)

          if check[:php_present] == :ok
            begin
              shell *args
              complete = true
            rescue Hobo::ExternalCommandError
              Hobo.ui.warning "Installing composer dependencies locally failed!"
            end
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
      to_install = []
      File.read("Vagrantfile").split("\n").each do |line|
        if line.match /#\s+ Hobo.vagrant_plugin (.*)/
          to_install << $1
        else
          next if line.match /^\s*#/
          next unless line.match /Vagrant\.require_plugin (.*)/
          to_install << $1
        end
      end

      to_install.each do |plugin|
        plugin.gsub!(/['"]*/, '')
        next if plugins.include? "#{plugin} "
        Hobo.ui.title "Installing vagrant plugin: #{plugin}"
        shell "vagrant", "plugin", "install", plugin, :realtime => true, :indent => 2
        Hobo.ui.separator
      end
    end
  end

  desc "Install chef dependencies"
  task :chef => [ "deps:gems" ] do
    locate "*Cheffile" do
      Hobo.ui.title "Installing chef dependencies via librarian"
      bundle_shell "librarian-chef", "install", "--verbose", :realtime => true, :indent => 2 do |line|
        line =~ /Installing.*</ ? line.strip + "\n" : nil
      end
      Hobo.ui.separator
    end

    locate "*Berksfile" do
      Hobo.ui.title "Installing chef dependencies via berkshelf"
      bundle_shell "berks", "install", :realtime => true, :indent => 2
      version = bundle_shell "berks", "-v", :capture => true
      if version =~ /^[3-9]/
        shell "rm -rf cookbooks"
        bundle_shell "berks", "vendor", "cookbooks"
      else
        bundle_shell "berks", "install", "--path", "cookbooks"
      end
      Hobo.ui.separator
    end
  end
end
