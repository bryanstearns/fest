Feature: Festival Film Priorities Page
  In order to inform the scheduler
  I should be able to prioritize films in a festival

  Scenario: Viewing the priorities page
    Given a festival with films and screenings
    And I visit the priorities page
    Then I should see a list of all the films
