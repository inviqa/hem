module Hobo
  module Lib
    module HostCheck
      class << self
        include Hobo::Lib::HostCheck

        def check opts = {}
          opts = {
            :filter => nil,
            :raise => false
          }.merge(opts)

          results = {}
          methods = Hobo::Lib::HostCheck.public_instance_methods(false)
          methods.each do |method|
            next if opts[:filter] && !method.match(opts[:filter])

            if opts[:raise]
              self.send method, opts
            else
              begin
                self.send method, opts
                results[method] = :ok
              rescue Hobo::Error => error
                results[method] = error
              end
            end
          end

          return results
        end
      end
    end
  end
end
