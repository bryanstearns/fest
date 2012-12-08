Given /^a film( with .*)?$/ do |with_stuff|
  @film = create("film#{with_stuff}".gsub(' ', '_').to_sym)
end

When /^I visit the film edit page$/ do
  visit edit_film_path(@film)
end

Then /^I should see the screenings listed$/ do
  rows = page.all("tr.film td:first")
  rows.should have_at_least(2).items
  rows.map(&:text).should eq(@festival.films.map(&:name))
end
