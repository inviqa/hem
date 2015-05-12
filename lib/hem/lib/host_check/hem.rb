module Hobo
  module Lib
    module HostCheck
      def latest_hobo_version opts
        require 'semantic'

        installed = ::Semantic::Version.new Hobo::VERSION

        return if installed >= get_latest_hobo_version

        if opts[:raise]
          answer = Hobo.ui.ask("A new version of hobo is available. Would you like to install it?", :default => 'y')

          if answer =~ /^[yY](es)?/
            Hobo.ui.success "Installing new version... please wait"
            shell "gem install hobo-inviqa", :realtime => true
            Hobo.ui.success "Installed"
            Hobo.relaunch!
          end
        else
          raise Hobo::HostCheckError.new("A new version of hobo is available", "Install it with `gem install hobo-inviqa`")
        end
      end

      private

      def get_latest_hobo_version
        require 'semantic'
        require 'net/http'
        one_day = 3600 * 24
        FileUtils.mkdir_p(Hobo.config_path)
        file = File.join(Hobo.config_path, 'latest')
        if !File.exists? file or File.mtime(file) < Time.now - one_day
          Hobo.ui.success "Checking for new hobo version..."
          uri = URI.parse('http://s3-eu-west-1.amazonaws.com/inviqa-hobo/version.txt')
          begin
            http = Net::HTTP.new(uri.host, uri.port)
            http.open_timeout = 2
            http.read_timeout = 2

            response = http.get(uri.path)

            if response.is_a? Net::HTTPOK
              File.write(
                file,
                response.body
              )
            end
          rescue Exception => e
            Hobo.ui.error "The hobo version check failed"
            # NOP - Many reasons for failure (network, disk full etc)
            # This is not a critical enough check to warrant bailing entirely if it fails
          end
        end
        latest = File.read(file).strip if File.exists?(file)
        ::Semantic::Version.new(latest || Hobo::VERSION)
      end
    end
  end
end
