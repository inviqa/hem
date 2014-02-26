require 'net/http'
require 'uri'

module Hobo
  module Helper
    def http_download url, target_file, opts = {}
      opts = { :progress => Hobo.method(:progress) }.merge(opts)
      uri = URI.parse(url)
      size = 0
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'

      # TODO: May want to verify SSL validity...
      # http://notetoself.vrensk.com/2008/09/verified-https-in-ruby/#comment-22252
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      http.start do
        begin
          file = open(target_file, 'wb+')
          http.request_get(uri.path) do |response|
            size = response.content_length
            response.read_body do |chunk|
              file.write(chunk)
              opts[:progress].call(
                target_file,
                chunk.length,
                size,
                :update
              ) if opts[:progress]
            end
          end
        ensure
          opts[:progress].call(target_file, 0, size, :finsh) if opts[:progress]
          file.close
        end
      end
    end
  end
end

include Hobo::Helper
