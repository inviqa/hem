require 'aws-sdk'
require 'fileutils'
require 'ruby-progressbar'

module Hobo
  module Lib
    class S3Sync
      include Hobo::Logging

      def initialize key_id, secret
        opts = {
          :access_key_id => key_id,
          :secret_access_key => secret,
          :verify_response_body_content_length => false
        }

        logger.debug("s3sync: Options #{opts}")

        @s3 = AWS::S3.new opts
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
          Remote.new(@s3, parsed.host, parsed.path) :
          Local.new(uri)
      end

      def sync source, dest, opts = {}
        opts = { :progress => method(:progress) }.merge(opts)

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

          written = 0
          size = source_file.size
          destination_file.write({ :size => source_file.size }) do |buffer, bytes|
            chunk = source_file.read(bytes)
            buffer.write(chunk)
            written += chunk.length
            opts[:progress].call(file, written, size, :update)
          end

          destination_file.close
          source_file.close

          opts[:progress].call(file, written, size, :finish)
        end

        delta[:remove].each do |file|
          logger.debug("s3sync: Removing #{file}")
          destination_io.rm(file)
        end

        return delta
      end

      def progress file, written, total, type
        opts = {
          :title => file,
          :total => total,
          :format => "%t [%B] %p%% %e"
        }

        # Hack to stop newline spam on windows
        opts[:length] = 79 if Gem::win_platform?

        @progress ||= {}
        @progress[file] ||= ProgressBar.create(opts)

        case type
          when :update
            @progress[file].progress = written
          when :finished
            @progress[file].finish
        end
      end


      class Local
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
          file_path = File.join(@path, file)
          FileUtils.mkdir_p File.dirname(file_path)
          LocalFile.new File.open(file_path, mode)
        end

        def rm file
          File.unlink file
        end
      end

      class Remote
        include Hobo::Logging

        def initialize s3, bucket, prefix
          @s3 = s3
          @bucket = bucket
          @prefix = prefix ? "#{prefix.gsub(/^\//, '').chomp('/')}/" : ""
        end

        def ls
          out = {}
          logger.debug("s3sync: Listing remote bucket: #{@bucket} w/ prefix #{@prefix}")
          @s3.buckets[@bucket].objects.with_prefix(@prefix).each do |file|
            filename = file.key.gsub(/^#{@prefix}/, '')
            next if filename == ""
            out[filename] = file.etag.gsub('"', '')
          end
          return out
        end

        def open file, mode
          s3_key = File.join(@prefix, file)
          RemoteFile.new @s3.buckets[@bucket].objects[s3_key], @prefix
        end

        def rm file
          s3_key = File.join(@prefix, file)
          @s3.buckets[@bucket].objects[s3_key].delete
        end
      end

      class LocalFile
        def initialize file
          @file = file
        end

        def buffer
          # NOP
        end

        def read bytes
          @file.read bytes
        end

        def write opts = {}
          opts = { :chunk_size => 4096 }.merge(opts)
          while @file.size < opts[:size] do
            yield @file, opts[:chunk_size]
          end
        end

        def size
          @file.size
        end

        def close
          @file.close
        end
      end

      class RemoteFile
        def initialize object, prefix
          @object = object
          @prefix = prefix
          @r_buffer, @w_buffer = IO.pipe
          @buffer_thread = nil
        end

        def buffer
          @buffer_thread = Thread.new do
            @object.read do |chunk|
              @w_buffer.write chunk
            end
          end
        end

        def read bytes
          @r_buffer.readpartial(bytes)
        end

        def write opts = {}
          s3_opts = { :single_request => true, :content_length => opts[:size] }
          @object.write s3_opts do |buffer, bytes|
            yield buffer, bytes
          end
        end

        def size
          @object.content_length
        end

        def close
          @r_buffer.close
          @w_buffer.close
          @buffer_thread.exit if @buffer_thread
        end
      end
    end
  end
end