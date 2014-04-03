module Hobo
  module Lib
    module S3
      module Local
        class IoHandler
          include Hobo::Logging

          def initialize path
            @path = path
          end

          def ls
            logger.debug("s3sync: Listing local directory: #{@path}")
            out = {}
            dir = "#{@path.chomp('/')}/"
            files = Dir.glob("#{dir}**/*")
            files.each do |file|
              out[file.gsub(/^#{dir}/, '')] = Digest::MD5.file(file).hexdigest
            end
            return out
          end

          def open file, mode
            file_path = ::File.join(@path, file)
            FileUtils.mkdir_p ::File.dirname(file_path)
            File.new ::File.open(file_path, mode)
          end

          def rm file
            ::File.unlink ::File.join(@path, file)
          end
        end
      end
    end
  end
end