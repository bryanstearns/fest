Feature: Festival Film Priorities Page
  In order to inform the scheduler
  I should be able to prioritize films in a festival

  Scenario: Viewing the priorities page
    Given a festival with films and screenings
    And I visit the priorities page
    Then I should see a list of all the films

  @javascript
  Scenario: Trying to prioritize when not logged in
    Given a festival with films and screenings
    And I am not logged in
    And I visit the priorities page
    And I might get an alert
    When I set a film priority
    Then I should see an alert saying 'sign in to manage your schedule'

  @javascript
  Scenario: Prioritizing a film
    Given a festival with films and screenings
    And I am logged in
    And I visit the priorities page
    And I might get an alert
    When I set a film priority
    Then I should not see an alert
    And the film priority should be set

  @javascript
  Scenario: Rating a film
    Given a festival with films and screenings
    And I am logged in
    And I visit the priorities page
    And I might get an alert
    When I set a film rating
    Then I should not see an alert
    And the film rating should be set
