module Hem
  module ErrorHandlers
    module ExitCodeMap
      DEFAULT_EXIT_CODE = 128
      EXIT_CODES = {
        'Interrupt' => 1,
        'Hem::ExternalCommandError' => 3,
        'Hem::InvalidCommandOrOpt' => 4,
        'Hem::MissingArgumentsError' => 5,
        'Hem::UserError' => 6,
        'Hem::ProjectOnlyError' => 7,
        'Hem::HostCheckError' => 8,
        'Hem::Error' => 9
      }
    end
  end
end
