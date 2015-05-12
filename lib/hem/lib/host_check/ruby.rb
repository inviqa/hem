module Hem
  module Lib
    module HostCheck
      def not_using_system_ruby opts
        return if Hem.windows?
        advice = <<-EOF
You're using a system ruby install which can cause issues with installing Gems and running some older projects.

rbenv is HIGHLY recommended.

You can install it with the following command:
  curl https://raw.github.com/fesplugas/rbenv-installer/master/bin/rbenv-installer | bash

Once installed, run the following to set it as the default ruby and re-install hem-inviqa:
  rbenv install 1.9.3-p448 && rbenv global 1.9.3-448 && gem install hem-inviqa
EOF
	require "rbconfig"
	which = File.join(RbConfig::CONFIG["bindir"], RbConfig::CONFIG["ruby_install_name"])
        unless which =~ /\.rbenv|\.rvm|jruby/
          raise Hem::HostCheckError.new("Hem is running under a system ruby", advice)
        end
      end

      def system_paths_for_ruby opts
        return if Hem.windows?

        advice = <<-EOF
The ordering of your system paths may cause a problem with Gems.

Unfortunately we can't automatically fix this for you at this time.

Please seek assistance.

Your paths were detected as:

#{ENV['PATH'].split(':').join("\n")}
EOF

        paths = ENV['PATH'].split(':')
        system_path_found = false
        ruby_path_found = false
        paths.each do |path|
          system_before_ruby = system_path_found && !ruby_path_found
          ruby_after_system = path =~ /\.rbenv|\.rvm/ && system_path_found
          raise Hem::HostCheckError.new("System paths appear to be mis-ordered", advice) if system_before_ruby or ruby_after_system

          ruby_path_found = true if path =~ /\.rbenv|\.rvm/
          system_path_found = true if path =~ /\/usr\/bin|\/usr\/local\/bin/
        end
      end
    end
  end
end
