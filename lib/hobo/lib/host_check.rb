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

            name = method.to_s.gsub('_', ' ')
            name[0] = name[0].upcase
            if opts[:raise]
              self.send method
            else
              begin
                self.send method
                results[name] = :ok
              rescue Hobo::Error => error
                results[name] = error
              end
            end
          end

          return results
        end
      end
    end
  end
end
