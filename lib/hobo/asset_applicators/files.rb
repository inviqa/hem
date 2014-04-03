# Built in applicators
Hobo.asset_applicators.register /.*\.files\.(tgz|tar\.gz|tar\.bz2)/ do |file|
  Hobo.ui.title "Applying file dump (#{file})"
  vm_shell "tar -xvf #{file.shellescape}"
end
