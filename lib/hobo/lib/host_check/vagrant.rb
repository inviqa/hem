require 'semantic'

module Hobo
  module Lib
    module HostCheck
      def vagrant_version
        version = shell "vagrant --version", :capture => true
        version.gsub!(/^Vagrant /, '')
        version = ::Semantic::Version.new version
        minimum_version = ::Semantic::Version.new "1.3.5"
        raise "Vagrant too old" if version < minimum_version
      end
    end
  end
end