module Hem
  module Lib
    module HostCheck
      def latest_hem_version opts
        require 'semantic'

        installed = ::Semantic::Version.new Hem::VERSION

        return if installed >= get_latest_hem_version

        if opts[:raise]
          answer = Hem.ui.ask("A new version of hem is available. Would you like to install it?", :default => 'y')

          if answer =~ /^[yY](es)?/
            Hem.ui.success "Installing new version... please wait"
            shell "gem install hem-inviqa", :realtime => true
            Hem.ui.success "Installed"
            Hem.relaunch!
          end
        else
          raise Hem::HostCheckError.new("A new version of hem is available", "Install it with `gem install hem-inviqa`")
        end
      end

      private

      def get_latest_hem_version
        require 'semantic'
        require 'net/http'
        one_day = 3600 * 24
        FileUtils.mkdir_p(Hem.config_path)
        file = File.join(Hem.config_path, 'latest')
        if !File.exists? file or File.mtime(file) < Time.now - one_day
          Hem.ui.success "Checking for new hem version..."
          uri = URI.parse('http://s3-eu-west-1.amazonaws.com/inviqa-hem/version.txt')
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
            Hem.ui.error "The hem version check failed"
            # NOP - Many reasons for failure (network, disk full etc)
            # This is not a critical enough check to warrant bailing entirely if it fails
          end
        end
        latest = File.read(file).strip if File.exists?(file)
        ::Semantic::Version.new(latest || Hem::VERSION)
      end
    end
  end
end
