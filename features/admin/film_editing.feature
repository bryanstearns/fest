Feature: Film editing
  As an administrator
  In order to manage festivals
  I should be able to create and edit films

  Scenario: List films
    Given a festival with films
    And I am logged in as an administrator
    When I visit the festival films page
    Then I should see the films listed
