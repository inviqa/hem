module Hobo
  module Lib
    module S3
      module Local
        class File
          def initialize file
            @file = file
          end

          def buffer
            # NOP
          end

          def size
            @file.size
          end

          def close
            @file.close
          end

          def read_io
            @file
          end

          def copy_from io, opts = {}, &block
            begin
              while (data = io.readpartial 16984) do
                @file.write data
                yield data if block_given?
              end
            rescue EOFError
              # NOP
            end
          end
        end
      end
    end
  end
end
