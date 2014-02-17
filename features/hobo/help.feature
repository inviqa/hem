Feature: Hobo help
  Scenario: --help should show help
    When I run `hobo --help`
    Then the output should contain "Usage:"
    And the output should contain "Global options:"
    And the output should contain "Commands:"

  Scenario: --h should show help
    When I run `hobo --help`
    Then the output should contain "Usage:"
    And the output should contain "Global options:"
    And the output should contain "Commands:"

  Scenario: --ansi should show invertable help
    When I run `hobo --help`
    Then the output should contain "(Disable with --no-ansi)"