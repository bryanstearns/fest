Feature: Festival Show Page
  In order to manage my festival schedule
  I should see the festival schedule

  Scenario: Schedule grid display
    Given a festival with films and screenings
    And I visit the festival page
    Then I should see a grid for each day of the festival
    And I should see the last-revised time of the festival

#  Scenario: Unschedule all screenings
#    Given pending

  Scenario: Downloading an icalendar file
    Given a festival with films and screenings
    And I am logged in as an administrator
    And I have scheduled at least one film
    When I visit the festival page
    And I visit the calendar link
    Then I should download a calendar with my films

#  Scenario: Downloading a PDF
#    Given pending
