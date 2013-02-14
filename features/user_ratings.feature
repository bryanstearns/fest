Feature: Festival Ratings Page
  In order to interact with the community
  I should be able to see a friend's film ratings

  Scenario: Show ratings page
    Given a user with ratings
    And I am not logged in
    And I visit their user ratings page
    Then I should see their film ratings
