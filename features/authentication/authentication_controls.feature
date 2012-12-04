Feature: Already authenticated
  To avoid confusion
  As a user signed in with an account
  I should not see the sign up link

  Background:
    Given I am logged in
    When I visit the home page
    Then I should not see the Sign Up button
