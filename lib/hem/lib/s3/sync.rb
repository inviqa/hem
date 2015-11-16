module Hem
  module Lib
    module S3
      class Sync
        include Hem::Logging

        def initialize opts = {}
          require 'aws-sdk'

          @opts = {
            :access_key_id => nil,
            :secret_access_key => nil,
            :region => 'eu-west-1',
            :retry_limit => 15
          }.merge(opts)

          if Hem.windows?
            Aws.config[:ssl_ca_bundle] = File.expand_path('../../../../../ssl/ca-bundle-s3.crt', __FILE__)
          end

          handle_s3_error do
            # AWS::S3 is flakey about actually raising this error when nil is provided
            [:access_key_id, :secret_access_key].each do |k|
              raise Aws::Errors::MissingCredentialsError if @opts[k].nil?
            end
          end

          logger.debug("s3sync: Options #{@opts}")
        end

        def sync source, dest, opts = {}
          delta = {:add => [], :remove => []}

          handle_s3_error do
            opts = {
              :delete => true,
              :dry => false,
              :progress => Hem.method(:progress)
            }.merge(opts)

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
            break if opts[:dry]

            delta[:add].each do |file|
              logger.debug("s3sync: Synchronizing #{file}")
              source_file = source_io.open(file, "r")
              destination_file = destination_io.open(file, "wb+")

              source_file.buffer

              size = source_file.size
              destination_file.copy_from(source_file.read_io, :content_length => size) do |chunk|
                opts[:progress].call(file, (chunk || '').length, size, :update)
              end

              destination_file.close
              source_file.close

              opts[:progress].call(file, 0, size, :finish)
            end
            break unless opts[:delete]

            delta[:remove].each do |file|
              logger.debug("s3sync: Removing #{file}")
              destination_io.rm(file)
            end
          end

          return delta
        end

        private

        def s3
          @s3 ||= Aws::S3::Resource.new @opts
        end

        def handle_s3_error
          exception = Hem::Error.new("Could not sync assets")
          begin
            yield
          rescue Errno::ENETUNREACH
            Hem.ui.error "  Could not contact Amazon servers."
            Hem.ui.error "  This can sometimes be caused by missing AWS credentials"
            raise exception
          rescue Aws::S3::Errors::NoSuchBucket
            Hem.ui.error "  Asset bucket #{Hem.project_config.asset_bucket} does not exist!"
            # We allow this one to be skipped as there are obviously no assets to sync
          rescue Aws::S3::Errors::AccessDenied
            Hem.ui.error "  Your AWS key does not have access to the #{Hem.project_config.asset_bucket} S3 bucket!"
            Hem.ui.error "  Please request access to this bucket from your TTL or via an internal support request"
            raise exception
          rescue Aws::Errors::MissingCredentialsError
            Hem.ui.warning "  AWS credentials not set!"
            Hem.ui.warning "  Please request credentials from internalsupport@inviqa.com or in #devops and configure them with `hem config`"
            raise exception
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
