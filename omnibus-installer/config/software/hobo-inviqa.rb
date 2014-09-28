name "hobo-inviqa"
default_version "0.0.15"

if windows?
  dependency "ruby-windows"
else
  dependency "ruby"
  dependency "rubygems"
end
dependency "openssl-customization"
dependency "rubygems-customization"

# Pre-compile lib dependencies
dependency "dep-selector-libgecode"
dependency "nokogiri"

# The devkit has to be installed after rubygems-customization so the
# file it installs gets patched.
dependency "ruby-windows-devkit" if windows?

build do
  gem "install hobo-inviqa -n #{install_dir}/bin --no-rdoc --no-ri -v #{version}"
end
