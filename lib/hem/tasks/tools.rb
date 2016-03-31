desc "Tasks to retrieve common tools"
hidden
namespace :tools do

  desc "Fetch composer"
  task :composer do
    bin_file = File.join(Hem.project_bin_path, "composer.phar")
    unless File.exists?(bin_file)
      Hem.ui.success "Getting composer"
      FileUtils.mkdir_p File.dirname(bin_file)
      run "cd bin && php -r \"readfile('https://getcomposer.org/installer');\" | php", :realtime => true, :indent => 2
    else
      Hem.ui.success "Composer already available in bin/composer.phar"
    end
    Hem.ui.separator
  end
end
