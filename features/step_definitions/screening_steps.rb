Given /^a film( with .*)?$/ do |with_stuff|
  @film = create("film#{with_stuff}".gsub(' ', '_').to_sym)
end

When /^I visit the film page$/ do
  visit film_path(@film)
end

Then /^I should see the screenings listed$/ do
  rows = page.all("table#screenings tr.screening")
  rows.should have_at_least(2).items
  @film.screenings.zip(rows).each do |screening, row|
    row.find("td:first-child a")["href"].should eq(edit_screening_path(screening))
  end
end
