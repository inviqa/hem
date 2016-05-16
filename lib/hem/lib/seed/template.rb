module Hem
  module Lib
    module Seed
      class Template
        def initialize(config)
          @config = config
        end

        def config
          @config
        end

        def render(content, filename)
          erb = ERB.new(content)
          erb.filename = filename
          erb.result binding
        end
      end
    end
  end
end