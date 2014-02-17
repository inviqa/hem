module Hobo
  module Lib
    module HostCheck
      def git_present
        begin
          shell "git --version"
        rescue Errno::ENOENT
          raise Hobo::MissingDependency.new("ssh")
        end
      end

      def git_config_name_set
        begin
          shell "git config user.name"
        rescue Hobo::ExternalCommandError
          Hobo.ui.error "You must provide git with your full name"
          name = Hobo.ui.ask "Full name"
          shell "git config --global user.name #{name.shellescape}"
        end
      end

      def git_config_email_set
        begin
          shell "git config user.email"
        rescue Hobo::ExternalCommandError
          email = Hobo.ui.ask "Email address"
          shell "git config --global user.email #{email.shellescape}"
        end
      end

      def git_autocrlf_disabled
        return true
        begin
          value = shell "git config core.autocrlf", :capture => true
          if value != "false"
            Hobo.ui.error "You're using git with autocrlf!"
            Hobo.ui.error "This setting can cause problems executing scripts within VMs."
            Hobo.ui.error "If you've had it enabled for a while, you'll need to check out all of your repositories again if you change it."
            disable = Hobo.ui.ask "Would you like to disable this setting?", :default => true
            if disable
              shell "git config --global core.autocrlf false"
              Hobo.ui.success "Disabled autocrlf\nYou can re-enable it by executing `git config --global core.autocrlf true"
            end

          end
        rescue Hobo::ExternalCommandError
          # NOP
        end
      end
    end
  end
end