# Built in applicators
Hem.asset_applicators.register 'files', /.*\.files\.(tgz|tar\.gz|tar\.bz2)/ do |file, _|
  Hem.ui.title "Applying file dump (#{file})"
  run_command "tar -xvf #{file.shellescape}"
end
