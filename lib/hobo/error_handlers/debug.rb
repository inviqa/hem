module Hobo
  module ErrorHandlers
    class Debug
      def handle error
        raise error
      end
    end
  end
end