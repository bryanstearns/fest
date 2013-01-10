
Given /^I visit the priorities page$/ do
  visit festival_priorities_path(@festival)
end

Then /^I should see a list of all the films$/ do
  films_by_name = @festival.films.to_a.sort_by {|f| f.name }
  films_list = page.find("table#picks")
  films_list.should have_content(films_by_name.first.name)
end
