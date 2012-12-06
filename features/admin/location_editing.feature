Feature: Location editing
  As an administrator
  In order to manage festivals
  I should be able to create and edit locations and venues

  Scenario: List locations and venues
    Given a location with venues
    And I am logged in as an administrator
    When I visit the locations page
    Then I should see the locations and venues listed in groups
