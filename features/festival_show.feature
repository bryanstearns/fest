Feature: Festival Show Page
  In order to manage my festival schedule
  I should see the festival schedule

  Scenario: Schedule grid display
    Given a festival with films and screenings
    And I visit the festival page
    Then I should see a grid for each day of the festival
    And I should see the last-revised time of the festival

  #@javascript
  Scenario: Unschedule all screenings
    Given a festival with films and screenings
    And I am logged in
    And I have scheduled at least one film
    When I visit the festival page
    And I click the unselect-all-screenings button
    Then I should not have screenings selected

  Scenario: Downloading an icalendar file
    Given a festival with films and screenings
    And I am logged in
    And I have scheduled at least one film
    When I visit the festival page
    And I visit the calendar link
    Then I should download a calendar with my films

  Scenario: Downloading a schedule PDF
    Given a festival with films and screenings
    And I am logged in
    And I have scheduled at least one film
    When I visit the festival page
    And I visit the PDF link
    Then I should download a PDF with my films
