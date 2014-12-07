Feature: Enabling
  In order to manage the site
  Visitors are subject to runtime enabling/disabling of features

  Scenario: Disabled access
    Given the site is disabled
    When I visit the home page
    Then I should be told that we're closed
    And the HTTP status should be 503

  Scenario: Disabled signin by form
    Given sign_in is disabled
    And I exist as a user
    And I am not an administrator
    When I visit the signin page
    Then I should see the home page
    And I should be told that signins are off
    And I should be signed out

  Scenario: Disabled signin when already authenticated
    Given I exist as a user
    And I am not an administrator
    And I am logged in
    And sign_in is disabled
    When I visit a page requiring authentication
    Then I should see the home page
    And I should be told that signins are off
    And I should be signed out

  Scenario: Disabled signup - signup page
    Given I am not logged in
    When sign_up is disabled
    And I visit the signup page
    Then I should be told to try to sign up another time

  Scenario: Enabled signup with a festival - home page
    Given I am not logged in
    And an upcoming festival exists
    When sign_up is enabled
    And I visit the home page
    Then I should see the festival "now playing"
    And I should be able to get started

  Scenario: Disabled signup with a festival - home page
    Given I am not logged in
    And an upcoming festival exists
    When sign_up is disabled
    And I visit the home page
    Then I should see the festival "coming soon"
    And I should not be able to get started

  Scenario: Disabled signup & no festival - home page
    Given I am not logged in
    When sign_up is disabled
    And I visit the home page
    Then I should not be able to get started
