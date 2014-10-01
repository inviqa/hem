name "hobo-inviqa"
maintainer "Mike Simons"
homepage "http://inviqa.com"

install_dir     "#{default_root}/#{name}"
build_version   "0.0.15"
build_iteration 1


override :nokogiri,       version: "1.6.3.1"
override :ruby,           version: "2.1.2"
override :'ruby-windows', version: "2.0.0-p451"
override :rubygems,       version: "2.4.1"

# creates required build directories
dependency 'preparation'

# omnibus dependencies/components
dependency "hobo-inviqa"

# we make this happen after the fact so the gem installs in hobo-inviqa don't get messed up
dependency "rubygems-customization"

# version manifest file
dependency 'version-manifest'

exclude "**/.git"
exclude "**/bundler/git"
exclude "**/embedded/man"
exclude "**/cache/**.gem"
exclude "**/hobo-inviqa/omnibus-installer"
exclude "**/hobo-inviqa/specs"

package :pkg do
  identifier "com.inviqa.pkg.hobo"
end

package :msi do
  upgrade_code "A58AC989-0E19-42BC-A13F-415F274ED972"
end

compress :dmg
