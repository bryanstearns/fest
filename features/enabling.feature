Feature: Enabling
  In order to manage the site
  Visitors are subject to runtime enabling/disabling of features

  Scenario: Disabled access
    When the site is disabled
    And I visit the home page
    Then I should be told that we're closed
    And the HTTP status should be 503
