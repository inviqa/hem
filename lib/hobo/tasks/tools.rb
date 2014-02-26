namespace :tools do
  task :composer do
    bin_file = File.join(Hobo.project_bin_path, "composer.phar")
    unless File.exists?(bin_file)
      Hobo.ui.success "Getting composer"
      FileUtils.mkdir_p File.dirname(bin_file)
      vm_shell "cd bin && php -r \"readfile('https://getcomposer.org/installer');\" | php", :realtime => true, :indent => 2
    else
      Hobo.ui.success "Composer already available in bin/composer.phar"
    end
    Hobo.ui.separator
  end
end
