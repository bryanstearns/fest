
Given /^I visit the priorities page$/ do
  visit festival_priorities_path(@festival)
end

Given /^I might get an alert$/ do
  page.evaluate_script('window.alert = function(message) { window.alert_message = message; return true; }')
end

When /^I set a film (priority|rating)$/ do |attr|
  @film = @festival.films.first
  if @user
    pick = @festival.picks.where(user_id: @user.id, film_id: @film.id).first
    pick.should be_nil
  end
  first_image = all("#film_#{@film.id}_#{attr == 'rating' ? 'stars' : 'dots'} img")[1]
  first_image.click
  find("#film_#{@film.id}_progress.obscured") # wait for ajax
end

Then /^I should see a list of all the films$/ do
  films_by_name = @festival.films.to_a.sort_by {|f| f.name }
  films_list = page.find("table#picks")
  films_list.should have_content(films_by_name.first.name)
end

Then /^I should see an alert saying '([^\']+)'$/ do |msg|
  page.evaluate_script('window.alert_message').should match(Regexp.new(msg))
end

Then /^I should not see an alert$/ do
  page.evaluate_script('window.alert_message').should be_nil
end

Given /^the film (priority|rating) should be set$/ do |attr|
  pick = @festival.picks.where(user_id: @user.id, film_id: @film.id).first
  pick.send(attr).should == ((attr == 'rating') ? 1 : 0)
end
