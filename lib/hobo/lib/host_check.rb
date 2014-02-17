module Hobo
  module Lib
    module HostCheck
      class << self
        include Hobo::Lib::HostCheck

        def check silent = true
          methods = Hobo::Lib::HostCheck.public_instance_methods(false)
          methods.each do |method|
            name = method.to_s.gsub('_', ' ')
            name[0] = name[0].upcase
            begin
              self.send method
              Hobo.ui.success "#{name}: OK" unless silent
            rescue
              Hobo.ui.error "#{name}: FAILED" unless silent
            end
          end
        end
      end
    end
  end
end