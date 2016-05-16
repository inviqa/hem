module Hem
  module Lib
    module Seed
      class Replacer
        def replace(path, tokens)
          unless !tokens.instance_of?(Hash)
            raise "Invalid token list (expected Hash)"
          end

          return search_replace(path, tokens)
        end

        private

        def search_replace(path, tokens, &block)
          require 'erb'

          template = Template.new(tokens)
          Hem::Helper.locate('*.erb', nil, path: path, type: 'files').each do |candidate|
            next unless FileTest.file? candidate # Skip unless file

            content = File.read(candidate)
            next unless content.force_encoding("UTF-8").valid_encoding? # Skip unless file can be valid UTF-8

            content = template.render(content, candidate)

            File.delete(candidate)
            File.write(candidate.sub('.erb', ''), content)
          end
        end
      end
    end
  end
end
