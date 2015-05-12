Feature: Subcommands

  Scenario: Subcommand with --help should show command help
   When I run `hem test non-interactive  --help`
   Then the output should contain "hem test non-interactive [options]"

  Scenario: Namespace should show subcommands
    When I run `hem test`
    Then the output should contain "non-interactive"
    And the output should contain "Does non-interactive things"

  Scenario: Subcommand should execute
    When I run `hem test non-interactive` interactively
    And I type "Testing"
    Then the output should contain "Testing"
