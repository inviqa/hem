name "hobo-inviqa"
maintainer "Mike Simons"
homepage "http://inviqa.com"

install_dir     "/opt/hobo-inviqa"
build_version   "0.0.15"
build_iteration 1

# creates required build directories
dependency 'preparation'

# omnibus dependencies/components
dependency "hobo-inviqa"

# version manifest file
dependency 'version-manifest'

exclude '\.git*'
exclude 'bundler\/git'
exclude '*\.gem'
