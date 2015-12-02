# Built in applicators
Hem.asset_applicators.register /.*\.files\.(tgz|tar\.gz|tar\.bz2)/ do |file|
  Hem.ui.title "Applying file dump (#{file})"
  run_command "tar -xvf #{file.shellescape}"
end
