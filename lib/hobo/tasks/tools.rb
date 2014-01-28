namespace :tools do
  task :composer do
    bin_file = File.join(Hobo.project_bin_path, "composer.phar")
    unless File.exists?(bin_file)
      Hobo.ui.success "Getting composer.phar"
      FileUtils.mkdir_p File.dirname(bin_file)
      Dir.chdir File.dirname(bin_file) do
        shell "php", "-r", "eval('?>'.file_get_contents('https://getcomposer.org/installer'));", realtime: true, indent: 2
      end
      Hobo.ui.separator
    end
  end
end