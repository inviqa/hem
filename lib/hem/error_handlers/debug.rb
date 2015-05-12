module Hem
  module ErrorHandlers
    class Debug
      include Hem::ErrorHandlers::ExitCodeMap

      def handle error
        Hem.ui.error "\n(#{error.class}) #{error.message}\n\n#{(error.backtrace || []).join("\n")}"
        return EXIT_CODES[error.class.to_s] || DEFAULT_EXIT_CODE
      end
    end
  end
end
