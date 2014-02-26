module Hobo
  module ErrorHandlers
    class Debug
      include Hobo::ErrorHandlers::ExitCodeMap

      def handle error
        Hobo.ui.error "\n(#{error.class}) #{error.message}\n\n#{(error.backtrace || []).join("\n")}"
        return EXIT_CODES[error.class.to_s] || DEFAULT_EXIT_CODE
      end
    end
  end
end
