Feature: Festival editing
  As an administrator
  In order to manage festivals
  I should be able to create and edit them

  Scenario: An adminstrator can see Edit
    Given a festival
    And I am logged in
    And I am an administrator
    When I visit the festival page
    Then I should see an Edit link

  Scenario: Non admins should not see Edit
    Given a festival
    And I am logged in
    And I am not an administrator
    When I visit the festival page
    Then I should not see an Edit link
