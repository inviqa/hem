module Hobo
  module Lib
    module HostCheck
      def not_using_system_ruby
        return if Gem.win_platform?
        which = shell "which ruby", :capture => true
        unless which =~ /\.rbenc|\.rvm/
          Hobo.ui.error "You're using a system ruby install! rbenv is HIGHLY recommended"
          Hobo.ui.error "You can install it with the following command:\n"
          Hobo.ui.error "  curl https://raw.github.com/fesplugas/rbenv-installer/master/bin/rbenv-installer | bash\n"
          Hobo.ui.error "Once installed, run the following:\n"
          Hobo.ui.error "  rbenv install 1.9.3-p448 && rbenv global 1.9.3-448 && gem install hobo-inviqa"
          raise "System ruby in use"
        end
      end

      def system_paths_for_ruby
        return if Gem.win_platform?
        paths = ENV['PATH'].split(':')
        system_path_found = false
        ruby_path_found = false
        paths.each do |path|
          system_before_ruby = system_path_found && !ruby_path_found
          ruby_after_system = path =~ /\.rbenv|\.rvm/ && system_path_found
          raise "Bad system paths" if system_before_ruby or ruby_after_system

          ruby_path_found = true if path =~ /\.rbenv|\.rvm/
          system_path_found = true if path =~ /\/usr\/bin|\/usr\/local\/bin/
        end
      end

      def ruby_include_paths
        paths = $:
        bad_paths = paths.reject do |path|
          path.match /\.rbenv|\.rvm/
        end.compact.length > 0

        raise "Bad gem paths" if bad_paths
      end
    end
  end
end