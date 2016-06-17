module Hem
  module Lib
    module HostCheck
      def git_present opts
        advice = "The Git command could not be detected on your system.\n\n"
        if Hem.windows?
          advice += "Please install it from http://git-scm.com/downloads ensuring you select the 'Use git and unix tools everywhere' option."
        else
          advice += "Please install it using your package manager."
        end

        begin
          Hem::Helper.shell "git --version"
        rescue Errno::ENOENT
          raise Hem::HostCheckError.new("Git is missing", advice)
        end
      end

      def git_config_name_set opts
        advice = <<-EOF
You have not set your name in git config!

Please do so with the following command:
  git config --global user.name <your name here>
EOF
        begin
          Hem::Helper.shell "git config user.name"
        rescue Hem::ExternalCommandError
          raise Hem::HostCheckError.new("Git config is incomplete (Full name)", advice)
        end
      end

      def git_config_email_set opts
        advice = <<-EOF
You have not set your email in git config!

Please do so with the following command:
  git config --global user.email <your email here>
EOF

        begin
          Hem::Helper.shell "git config user.email"
        rescue Hem::ExternalCommandError
          raise Hem::HostCheckError.new("Git config is incomplete (Email)", advice)
        end
      end

      def git_autocrlf_disabled opts
        return unless Hem.windows?

        advice = <<-EOF
You're using git with the core.autocrlf option enabled.

This setting can often cause problems when you clone a repository on windows but need to execute the contents of that repository within a linux VM.

You can disable autocrlf globally with the following command:
  git config --global core.autocrlf false

Disabling this setting will cause git to see all line endings as changed in a repository that was cloned with it enabled.
As such, you must either enable it just for those repositories or delete and re-clone them with the setting disabled.

You can enable the setting on a per-clone basis by ensuring that you are in the project directory and executing the following command:
  git config core-autocrlf true
EOF
        begin
          value = Hem::Helper.shell "git config core.autocrlf", :capture => true
          if value != "false"
            raise Hem::HostCheckError.new("Git config has autocrlf enabled", advice)
          end
        rescue Hem::ExternalCommandError
          # NOP
        end
      end
    end
  end
end
