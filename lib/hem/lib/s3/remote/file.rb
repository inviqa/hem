module Hem
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
              @object.get do |chunk|
                @w_buffer.write chunk
              end
              @w_buffer.close # required for EOF
            end
          end

          def size
            @object.content_length
          end

          def close
            @r_buffer.close unless @r_buffer.closed?
            @w_buffer.close unless @w_buffer.closed?
            @buffer_thread.exit if @buffer_thread
          end

          def read_io
            @r_buffer
          end

          # This is a bit nasty but it gets the job done
          def copy_from io, opts = {}, &block
            ninety_gb = 1024 * (90000000) # arbitrarily high number
            opts[:multipart_threshold] = ninety_gb

            if block_given?
              io.instance_eval "
                def read bytes
                  data = super bytes
                  @block.call(data)
                  data
                end"
              io.instance_variable_set '@block', block
            end

            @object.upload_file(io, opts)
          end
        end
      end
    end
  end
end
