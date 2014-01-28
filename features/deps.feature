Feature: Dependencies

  Scenario: deps:gems should install Gemfile dependencies
    Given a file named "Gemfile" with:
      """
      source 'https://rubygems.org'
      gem 'bundler'
      """
    And an empty file named "Hobofile"
    When I run `hobo deps gems`
    Then the output should contain "Using bundler"
    And a file named "Gemfile.lock" should exist

  Scenario: deps:composer should install composer dependencies
    Given a file named "composer.json" with:
      """
      {
        "require": {
          "whatthejeff/fab": "*"
        }
      }
      """
    And an empty file named "Hobofile"
    When I run `hobo deps composer`
    Then the output should contain "Installing whatthejeff/fab"
    And a file named "composer.lock" should exist

  Scenario: deps:chef should install chef dependencies
    Given a file named "Cheffile" with:
      """
      site 'http://community.opscode.com/api/v1'
      cookbook 'apache2'
      """
    And an empty file named "Hobofile"
    And a file named "Gemfile" with:
      """
      source 'https://rubygems.org'
      gem 'librarian-chef'
      """
    When I run `bundle install`
    And I run `hobo deps chef`
    Then the output should contain "apache2"
    And a file named "Cheffile.lock" should exist