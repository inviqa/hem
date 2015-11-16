module Hem
  module Lib
    module S3
      module Remote
        class IoHandler
          include Hem::Logging

          def initialize s3, bucket, prefix
            @s3 = s3
            @bucket = bucket
            @prefix = prefix ? "#{prefix.gsub(/^\//, '').chomp('/')}/" : ""
          end

          def ls
            out = {}
            logger.debug("s3sync: Listing remote bucket: #{@bucket} w/ prefix #{@prefix}")
            @s3.bucket(@bucket).objects(:prefix => @prefix).each do |file|
              filename = file.key.gsub(/^#{@prefix}/, '')
              next if filename == ""
              out[filename] = file.etag.gsub('"', '')
            end
            return out
          end

          def open file, mode
            s3_key = ::File.join(@prefix, file)
            File.new @s3.bucket(@bucket).object(s3_key), @prefix
          end

          def rm file
            s3_key = ::File.join(@prefix, file)
            @s3.bucket(@bucket).object(s3_key).delete
          end
        end
      end
    end
  end
end
