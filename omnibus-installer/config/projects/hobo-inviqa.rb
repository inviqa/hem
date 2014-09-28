name "hobo-inviqa"
maintainer "Mike Simons"
homepage "http://inviqa.com"

install_dir     "#{default_root}/#{name}"
build_version   "0.0.15"
build_iteration 1

# creates required build directories
dependency 'preparation'

# omnibus dependencies/components
dependency "hobo-inviqa"

# version manifest file
dependency 'version-manifest'

exclude "**/.git"
exclude "**/bundler/git"

package :pkg do
  identifier "com.inviqa.pkg.hobo"
end

package :msi do
  upgrade_code "A58AC989-0E19-42BC-A13F-415F274ED972"
end

compress :dmg
