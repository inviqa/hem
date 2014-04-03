module Hobo
  module ErrorHandlers
    class Friendly
      include Hobo::ErrorHandlers::ExitCodeMap

      def handle error
        require 'tmpdir'
        log_file = File.join(Dir.tmpdir, 'hobo_error.log')

        # Not possible to match Interrupt class unless we use class name as string for some reason!
        case error.class.to_s
          when "Interrupt"
            Hobo.ui.warning "\n\nCaught Interrupt. Aborting\n"
          when "Hobo::ExternalCommandError"
            FileUtils.cp error.output.path, log_file

            File.open(log_file, "a") do |file|
              file.write "\n(#{error.class}) #{error.message}\n\n#{error.backtrace.join("\n")}"
            end

            Hobo.ui.error <<-ERROR

  The following external command appears to have failed (exit status #{error.exit_code}):
    #{error.command}

  The output of the command has been logged to #{log_file}
            ERROR
          when "Hobo::InvalidCommandOrOpt"
            Hobo.ui.error "\n#{error.message}"
            Hobo.ui.info error.cli.help_formatter.help if error.cli
          when "Hobo::MissingArgumentsError"
            Hobo.ui.error "\n#{error.message}"
            Hobo.ui.info error.cli.help_formatter.help(target: error.command) if error.cli
          when "Hobo::UserError"
            Hobo.ui.error "\n#{error.message}\n"
          when "Hobo::ProjectOnlyError"
            Hobo.ui.error "\nHobo requires you to be in a project directory for this command!\n"
          when "Hobo::HostCheckError"
            Hobo.ui.error "\nHobo has detected a problem with your system configuration:\n"
            Hobo.ui.warning error.advice.gsub(/^/, '  ')
          else
            File.write(log_file, "(#{error.class}) #{error.message}\n\n#{error.backtrace.join("\n")}")
            Hobo.ui.error <<-ERROR

  An unexpected error has occured:
    #{error.message}

  The backtrace has been logged to #{log_file}
            ERROR
        end

        return EXIT_CODES[error.class.to_s] || DEFAULT_EXIT_CODE
      end
    end
  end
end
