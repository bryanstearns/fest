Feature: Festival Show Page
  In order to manage my festival schedule
  I should see the festival schedule

  Scenario: Schedule grid display
    Given a festival with films and screenings
    And I visit the festival page
    Then I should see a grid for each day of the festival
    And I should see the last-revised time of the festival
