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
      end
    end
  end
end