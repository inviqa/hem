Feature: Basics
  Scenario: No arguments should show help
    When I run `hem`
    Then the output should contain "Usage:"

  Scenario: -v should show version
    When I run `hem -v`
    Then the output should contain "Hem version"

  Scenario: --version should show version
    When I run `hem --version`
    Then the output should contain "Hem version"

  Scenario: An invalid command should fail gracefully
    When I run `hem jibberjabber`
    Then the output should contain "Invalid command or option"
    And the exit status should be 4

  Scenario: An invalid option should fail gracefully
    When I run `hem --jibberjabber`
    Then the output should contain "Invalid command or option"
    And the exit status should be 4

  Scenario: --debug should display backtraces
    When I run `hem jibberjabber --debug`
    Then the output should contain "Hem::InvalidCommandOrOpt"

  Scenario: --no-ansi should disable ansi output
    When I run `hem --no-ansi`
    Then the output should not contain "33m"

  Scenario: --non-interactive should cause default options to be used
    When I run `hem test non-interactive --non-interactive`
    Then the output should contain "Used defaults"

  Scenario: --all should list all tasks
    When I run `hem --all`
    Then the output should contain "hem-debug"

  Scenario: --skip-host-checks should skip host checks
    Given "test_files/vagrant_fail/" is appended to the PATH environment variable
    When I run `hem --skip-host-checks`
    Then the output should not contain "Hem has detected a problem"
