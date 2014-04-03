namespace :tools do
  desc "Fetches the n98-magerun utility"
  task :n98magerun do
    FileUtils.mkdir_p "bin"
    vm_shell '"wget" --no-check-certificate "https://raw.github.com/netz98/n98-magerun/master/n98-magerun.phar" -O bin/n98-magerun.phar'
    FileUtils.chmod 0755, "bin/n98-magerun.phar"
  end
end

desc "Magento related tasks"
namespace :magento do

  desc "Setup script tasks"
  namespace :'setup-scripts' do
    desc "Run magento setup scripts"
    task :run => ['tools:n98magerun']  do
      Hobo.ui.success "Running setup scripts"
      vm_shell("bin/n98-magerun.phar sys:setup:incremental -n", :realtime => true, :indent => 2)
      Hobo.ui.separator
    end
  end

  desc "Cache tasks"
  namespace :cache do
    desc "Clear cache"
    task :clear => ['tools:n98magerun']  do
      Hobo.ui.success "Clearing magento cache"
      vm_shell("bin/n98-magerun.phar cache:flush", :realtime => true, :indent => 2)
      Hobo.ui.separator
    end
  end

  desc "Configuration related tasks"
  namespace :config do
    desc "Configure magento base URLs"
    task :'configure-urls' => ['tools:n98magerun'] do
      Hobo.ui.success "Configuring magento base urls"
      url = "http://#{Hobo.project_config.hostname}/"
      vm_shell("bin/n98-magerun.phar config:set web/unsecure/base_url '#{url}'", :realtime => true, :indent => 2)
      vm_shell("bin/n98-magerun.phar config:set web/secure/base_url '#{url}'", :realtime => true, :indent => 2)
      Hobo.ui.separator
    end

    desc "Enable magento errors"
    task :'enable-errors' do
      error_config = File.join(Hobo.project_path, 'public/errors/local.xml')

      FileUtils.cp(
          error_config + ".sample",
          error_config
      ) unless File.exists? error_config
    end

    desc "Create admin user"
    task :'create-admin-user' do
      initialized = vm_shell("bin/n98-magerun.phar admin:user:list | grep admin", :exit_status => true) == 0
      unless initialized
        Hobo.ui.success "Creating admin user"
        vm_shell("bin/n98-magerun.phar admin:user:create admin '' admin admin admin", :realtime => true, :indent => 2)
        Hobo.ui.separator
      end
    end

    desc "Enable rewrites"
    task :'enable-rewrites' do
      Hobo.ui.success "Enabling rewrites"
      vm_shell("bin/n98-magerun.phar config:set web/seo/use_rewrites 1", :realtime => true, :indent => 2)
      Hobo.ui.separator
    end
  end

  desc "Initializes magento specifics on the virtual machine after a fresh build"
  task :'initialize-vm' => [
    'magento:config:enable-errors',
    'tools:n98magerun',
    'magento:setup-scripts:run',
    'magento:config:configure-urls',
    'magento:config:create-admin-user',
    'magento:config:enable-rewrites',
    'magento:cache:clear'
  ]
end
