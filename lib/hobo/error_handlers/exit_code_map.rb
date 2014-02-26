module Hobo
  module ErrorHandlers
    module ExitCodeMap
      DEFAULT_EXIT_CODE = 128
      EXIT_CODES = {
        'Interrupt' => 1,
        'Hobo::ExternalCommandError' => 3,
        'Hobo::InvalidCommandOrOpt' => 4,
        'Hobo::MissingArgumentsError' => 5,
        'Hobo::UserError' => 6,
        'Hobo::ProjectOnlyError' => 7,
        'Hobo::HostCheckError' => 8
      }
    end
  end
end
