module Hem
  module Lib
    module Seed
      class Replacer
        # Matching files/directories to be excluded from replacements
        EXCLUDES = ["\\.git/", "^./bin", "^./lib", "^./spec"]

        def replace(path, tokens)
          if tokens.instance_of? Hash
            tokens = flat_hash(tokens)
          elsif !tokens.instance_of? Array
            raise "Invalid token list (expected Array or Hash)"
          end

          return search_replace(path, tokens)
        end

        private

        def search_replace(path, tokens, &block)
          require 'find'
          files = []
          excludes = Regexp.new(EXCLUDES.join("|"))
          Find.find(path) do |candidate|
            Find.prune if candidate =~ excludes  # Skip excluded
            next unless FileTest.file? candidate # Skip unless file

            content = File.read(candidate)
            next unless content.force_encoding("UTF-8").valid_encoding? # Skip unless file can be valid UTF-8

            match = false
            tokens.each do |token, replacement|
              token = "{{#{token.join('.')}}}"
              match = content.match(token)
              if match
                content.gsub!(token, replacement)
                files.push(candidate)
              end
            end

            File.write(candidate, content) if files.include? candidate
          end
          return files.uniq
        end

        # http://stackoverflow.com/questions/9647997/converting-a-nested-hash-into-a-flat-hash
        def flat_hash(hash, k = [])
          return {k => hash} unless hash.is_a?(Hash)
          hash.inject({}) do |h, v|
            h.merge! flat_hash(v[-1], k + [v[0]])
          end
        end
      end
    end
  end
end
