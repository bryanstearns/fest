Feature: Static Pages
  In order to understand the site and its status
  Visitors should see useful stuff on the home controller's static pages

  Scenario: Visiting the home page
    When I visit the home page
    Then I should see a welcome message

  Scenario: Visiting the maintenance page
    When I visit the maintenance page
    Then I should be told that we're closed
