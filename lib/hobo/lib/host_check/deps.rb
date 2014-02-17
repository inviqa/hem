module Hobo
  module Lib
    module HostCheck
      def ssh_present
        begin
          shell "ssh -V"
        rescue Errno::ENOENT
          raise Hobo::MissingDependency.new("ssh")
        end
      end

      def php_present
        begin
          shell "php -v"
        rescue Errno::ENOENT
          raise Hobo::MissingDependency.new("php")
        end
      end
    end
  end
end