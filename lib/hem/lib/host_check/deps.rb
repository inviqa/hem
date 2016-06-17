module Hem
  module Lib
    module HostCheck
      def ssh_present opts
        advice = "The SSH command could not be located on your system.\n\n"

        if Hem.windows?
          advice += "To make SSH available you must re-install git using the installer from http://git-scm.com/downloads ensuring you select the 'Use git and unix tools everywhere' option."
        else
          advice += "Please install openssh using your package manager."
        end

        begin
          Hem::Helper.shell "ssh -V"
        rescue Errno::ENOENT
          raise Hem::HostCheckError.new("SSH is missing", advice)
        end
      end

      def php_present opts
        advice = <<-EOF
The PHP command could not be located on your system.

This is an optional command that can speed up composer dependency installs.

Please install it from your package manager ensuring that the following command does not produce any errors:

  php -r "readfile('https://getcomposer.org/installer');" | php
EOF

        begin
          Hem::Helper.shell "php --version"
        rescue Errno::ENOENT
          raise Hem::HostCheckError.new("PHP is missing", advice)
        end
      end
    end
  end
end
