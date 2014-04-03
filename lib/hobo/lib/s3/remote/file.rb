module Hobo
  module Lib
    module S3
      module Remote
        class File
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
end