Feature: Film editing
  As an administrator
  In order to manage festivals
  I should be able to create and edit screenings

  Scenario: List screenings on a film
    Given a film with screenings
    And I am logged in as an administrator
    When I visit the film page
    Then I should see the screenings listed
