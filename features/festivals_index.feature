Feature: Festivals Index Page
  In order to choose a festival
  Visitors should see a list of festivals

  Scenario: Visiting the festivals index page
    When there are three festivals in two groups
    And I visit the festivals index page
    Then I should see the festivals listed in groups
