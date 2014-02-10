Feature: Basics
  Scenario: No arguments should show help
    When I run `hobo`
    Then the output should contain "Usage:"

  Scenario: -v should show version
    When I run `hobo -v`
    Then the output should contain "Hobo version"

  Scenario: --version should show version
    When I run `hobo --version`
    Then the output should contain "Hobo version"

  Scenario: An invalid command should fail gracefully
    When I run `hobo jibberjabber`
    Then the output should contain "Invalid command or option"
    And the exit status should be 4

  Scenario: An invalid option should fail gracefully
    When I run `hobo --jibberjabber`
    Then the output should contain "Invalid command or option"
    And the exit status should be 4

  Scenario: --debug should display backtraces
    When I run `hobo jibberjabber --debug`
    Then the output should contain "Hobo::InvalidCommandOrOpt"

  Scenario: --no-ansi should disable ansi output
    When I run `hobo --no-ansi`
    Then the output should not contain "33m"

  Scenario: --non-interactive should cause default options to be used
    When I run `hobo test non-interactive --non-interactive`
    Then the output should contain "Used defaults"