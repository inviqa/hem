module Hem
  module ErrorHandlers
    class Friendly
      include Hem::ErrorHandlers::ExitCodeMap

      def handle error
        require 'tmpdir'
        log_file = File.join(Dir.tmpdir, 'hem_error.log')

        # Not possible to match Interrupt class unless we use class name as string for some reason!
        case error.class.to_s
          when "Interrupt"
            Hem.ui.warning "\n\nCaught Interrupt. Aborting\n"
          when "Hem::ExternalCommandError"
            FileUtils.cp error.output.path, log_file

            File.open(log_file, "a") do |file|
              file.write "\n(#{error.class}) #{error.message}\n\n#{error.backtrace.join("\n")}"
            end

            Hem.ui.error <<-ERROR

  The following external command appears to have failed (exit status #{error.exit_code}):
    #{error.command}

  The output of the command has been logged to #{log_file}
            ERROR
          when "Hem::InvalidCommandOrOpt"
            Hem.ui.error "\n#{error.message}"
            Hem.ui.info error.cli.help_formatter.help if error.cli
          when "Hem::MissingArgumentsError"
            Hem.ui.error "\n#{error.message}"
            Hem.ui.info error.cli.help_formatter.help(target: error.command) if error.cli
          when "Hem::UserError"
            Hem.ui.error "\n#{error.message}\n"
          when "Hem::ProjectOnlyError"
            Hem.ui.error "\nHem requires you to be in a project directory for this command!\n"
          when "Hem::HostCheckError"
            Hem.ui.error "\nHem has detected a problem with your system configuration:\n"
            Hem.ui.warning error.advice.gsub(/^/, '  ')
          when "Hem::Error"
            Hem.ui.error "\n#{error.message}\n"
          else
            File.write(log_file, "(#{error.class}) #{error.message}\n\n#{error.backtrace.join("\n")}")
            Hem.ui.error <<-ERROR

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
