module Hobo
  module Lib
    module S3
      class Sync
        include Hobo::Logging

        def initialize opts = {}
          require 'aws-sdk'

          @opts = {
            :access_key_id => nil,
            :secret_access_key => nil,
            :verify_response_body_content_length => false,
            :max_retries => 15
          }.merge(opts)

          # AWS::S3 is flakey about actually raising this error when nil is provided
          [:access_key_id, :secret_access_key].each do |k|
            raise AWS::Errors::MissingCredentialsError if @opts[k].nil?
          end

          logger.debug("s3sync: Options #{@opts}")
        end

        def sync source, dest, opts = {}
          delta = {:add => [], :remove => []}

          handle_s3_error do
            opts = { :progress => Hobo.method(:progress) }.merge(opts)

            source_io = io_handler(source)
            destination_io = io_handler(dest)

            logger.debug("s3sync: Synchronzing (#{source_io.class.name} -> #{destination_io.class.name}")

            raise "S3 -> S3 synchronisation not supported" if source_io.is_a? Remote and destination_io.is_a? Remote

            source_listing = source_io.ls
            destination_listing = destination_io.ls
            logger.debug("s3sync: Source listing - #{source_listing}")
            logger.debug("s3sync: Destination listing - #{destination_listing}")

            delta = delta(source_listing, destination_listing)
            logger.debug("s3sync: Delta #{delta}")

            delta[:add].each do |file|
              logger.debug("s3sync: Synchronizing #{file}")
              source_file = source_io.open(file, "r")
              destination_file = destination_io.open(file, "wb+")

              source_file.buffer

              size = source_file.size
              destination_file.write({ :size => source_file.size }) do |buffer, bytes|
                chunk = source_file.read(bytes)
                buffer.write(chunk)
                opts[:progress].call(file, (chunk || '').length, size, :update)
              end

              destination_file.close
              source_file.close

              opts[:progress].call(file, 0, size, :finish)
            end

            delta[:remove].each do |file|
              logger.debug("s3sync: Removing #{file}")
              destination_io.rm(file)
            end
          end

          return delta
        end

        private

        def s3
          @s3 ||= AWS::S3.new @opts
        end

        def handle_s3_error
          begin
            yield
          rescue Errno::ENETUNREACH
            Hobo.ui.error "  Could not contact Amazon servers."
            Hobo.ui.error "  This can sometimes be caused by missing AWS credentials"
          rescue AWS::S3::Errors::NoSuchBucket
            Hobo.ui.error "  Asset bucket #{Hobo.project_config.asset_bucket} does not exist!"
          rescue AWS::S3::Errors::AccessDenied
            Hobo.ui.error "  Your AWS key does not have access to the #{Hobo.project_config.asset_bucket} S3 bucket!"
            Hobo.ui.error "  Please request access to this bucket from your TTL or via an internal support request"
          rescue AWS::Errors::MissingCredentialsError
            Hobo.ui.warning "  AWS credentials not set!"
            Hobo.ui.warning "  Either set the AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY env vars or run `hobo config` to set them jsut for hobo."
          end
        end

        def delta source, dest
          to_add = (source.sort - dest.sort).map(&:first)
          to_remove = (dest.sort - source.sort).map(&:first)
          to_remove = to_remove - to_add

          {
            :add => to_add,
            :remove => to_remove
          }
        end

        def io_handler uri
          parsed = URI.parse(uri)
          parsed.scheme == 's3' ?
            Remote::IoHandler.new(s3, parsed.host, parsed.path) :
            Local::IoHandler.new(uri)
        end
      end
    end
  end
end
