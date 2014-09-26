name "hobo-inviqa"
default_version "0.0.15"

dependency "ruby"
dependency "rubygems"

build do
  gem "install hobo-inviqa -n #{install_dir}/bin --no-rdoc --no-ri -v #{version}"
end
