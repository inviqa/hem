Feature: Plant

  Scenario: Plant without name should fail gracefully
    When I run `hobo seed plant`
    Then the output should contain "Not enough arguments for seed:plant"

  Scenario: Plant with name should prompt for repository and seed
    Given there is a seed called "testing" with:
      """
      test
      """
    And I run `hobo seed plant seed_plant_0` interactively
    And I type "git://test_repo"
    And I type "./testing"
    And I run `sleep 0.5`
    And I run `git --git-dir=seed_plant_0/.git remote show origin -n`
    Then the output should contain "git://test_repo"
    And the file "seed_plant_0/test" should contain "test"

  Scenario: Plant with name and --git-url should prompt for seed
    Given there is a seed called "testing" with:
      """
      test
      """
    When I run `hobo seed plant seed_plant_0 --git-url=git://test_repo` interactively
    And I type "./testing"
    And I run `sleep 0.5`
    And I run `git --git-dir=seed_plant_0/.git remote show origin -n`
    Then the output should contain "git://test_repo"
    And the file "seed_plant_0/test" should contain "test"

  Scenario: Plant with name, --git-url and --seed should not prompt
    Given there is a seed called "testing" with:
      """
      test
      """
    When I run `hobo seed plant seed_plant_0 --git-url=git://test_repo --seed=./testing`
    And I run `sleep 0.5`
    And I run `git --git-dir=seed_plant_0/.git remote show origin -n`
    Then the output should contain "git://test_repo"
    And the file "seed_plant_0/test" should contain "test"

  Scenario: Plant should replace placeholders
    Given there is a seed called "testing" with:
      """
      NAME:{{name}}
      SEED:{{seed.name}}
      """
    When I run `hobo seed plant seed_plant_0 --git-url=git://test_repo --seed=./testing`
    Then the file "seed_plant_0/test" should contain "NAME:seed_plant_0"
    And the file "seed_plant_0/test" should contain "SEED:testing"

  Scenario: Plant should fail gracefully with invalid seed
    When I run `hobo seed plant seed_plant_0 --git-url=git://test_repo --seed=./not-exist`
    Then the output should contain "The following external command appears to have failed"

  Scenario: Plant should fail gracefully if target directory exists
    Given there is a seed called "testing" with:
      """
      test
      """
    And an empty file named "seed_plant_0"
    When I run `hobo seed plant seed_plant_0 --git-url=git://test_repo --seed=./not-exist`
    Then the output should contain "seed_plant_0 already exists"
