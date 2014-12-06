
When /^I visit the festival films page$/ do
  visit admin_festival_films_path(@festival)
end
Then /^I should see the films listed$/ do
  rows = page.all("tr.film td:first")
  expect(rows).to have_at_least(2).items
  expect(rows.map(&:text)).to eq(@festival.films.map(&:name))
end
