module Hem
  module Lib
    module HostCheck
      def vagrant_version opts
        require 'semantic'
        begin
          version = shell "vagrant --version", :capture => true
          version.gsub!(/^Vagrant[^0-9]+/, '')
          version = ::Semantic::Version.new version.strip
          minimum_version = ::Semantic::Version.new "1.3.5"

          advice = <<-EOF
  The version of vagrant which you are using (#{version}) is less than the minimum required (#{minimum_version}).

  Please go to http://www.vagrantup.com/downloads.html and download the latest version for your platform.
  EOF
          raise Hem::HostCheckError.new("Vagrant is too old!", advice) if version < minimum_version
        rescue Errno::ENOENT
          advice = <<-EOF
Vagrant could not be detected on the path!

Please go to http://www.vagrantup.com/downloads.html and download the latest version for your platform.
EOF
          raise Hem::HostCheckError.new("Vagrant is not on the path", advice)
        rescue Hem::ExternalCommandError => error
          advice = <<-EOF
Vagrant produced an error while checking its presence.

This is usually caused by using the vagrant gem which is no longer supported.

Uninstall any gem version of vagrant with the following command selecting "yes" to any prompt:
  gem uninstall vagrant

You can then download and install the latest version from http://www.vagrantup.com/downloads.html

If you do not have any vagrant gems installed it may be possible that a gem such as vagrant-wrapper is installed and is failing.

Please seek assistance from #devops if this is the case.
EOF
          raise Hem::HostCheckError.new("Vagrant produced an error while checking presence", advice)
        end
      end
    end
  end
end
