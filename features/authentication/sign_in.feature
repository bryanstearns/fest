Feature: Sign in
  In order to access my saved stuff
  As a user
  I want to sign in

  Scenario: Signed out user sees the right nav links
    Given I am not logged in
    When I visit the home page
    Then I should see the signed-out navigation links

  Scenario: Signed in user sees the right nav links
    Given I am logged in
    When I visit the home page
    Then I should see the signed-in navigation links

  Scenario: User is not signed up
    Given I do not exist as a user
    When I sign in with valid credentials
    Then I see an invalid login message
    And I should be signed out

  Scenario: User signs in successfully
    Given I exist as a user
    And I am not logged in
    When I sign in with valid credentials
    Then I see a successful sign in message
    When I return to the site
    Then I should be signed in

  Scenario: User enters wrong email
    Given I exist as a user
    And I am not logged in
    When I sign in with a wrong email
    Then I see an invalid login message
    And I should be signed out

  Scenario: User enters wrong password
    Given I exist as a user
    And I am not logged in
    When I sign in with a wrong password
    Then I see an invalid login message
    And I should be signed out

  Scenario: User signs out
    Given I am logged in
    When I sign out
    Then I should see a signed out message
    When I return to the site
    Then I should be signed out
