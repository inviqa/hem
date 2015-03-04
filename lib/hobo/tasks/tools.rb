desc "Tasks to retrieve common tools"
hidden
namespace :tools do

  desc "Fetch composer"
  task :composer do
    bin_file = File.join(Hobo.project_bin_path, "composer.phar")
    unless File.exists?(bin_file)
      Hobo.ui.section "Getting composer" do
        FileUtils.mkdir_p File.dirname(bin_file)
        vm_shell "cd bin && php -r \"readfile('https://getcomposer.org/installer');\" | php", :realtime => true, :indent => 2, :container => 'app:app'
      end
    else
      Hobo.ui.section "Updating composer" do
        vm_shell "php bin/composer.phar self-update", :realtime => true, :indent => 2, :container => 'app:app'
      end
    end
  end
end
