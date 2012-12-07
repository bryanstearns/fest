
When /^I visit the festival films page$/ do
  visit festival_films_path(@festival)
end

Then /^I should see the films listed$/ do
  rows = page.all("tr.film td:first")
  rows.should have_at_least(2).items
  rows.map(&:text).should eq(@festival.films.map(&:name))
end
