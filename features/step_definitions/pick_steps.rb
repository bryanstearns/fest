include Countries::Helpers

Given /^I visit the priorities page( with by-country sorting|)$/ do |sorted|
  options = sorted ? { order: 'country' } : {}
  visit festival_priorities_path(@festival, options)
end

Given /^I might get an alert$/ do
  page.evaluate_script('window.alert = function(message) { window.alert_message = message; return true; }')
end

When /^I set a film (priority|rating)$/ do |attr|
  @film = @festival.films.first
  if @user
    pick = @festival.picks.where(user_id: @user.id, film_id: @film.id).first
    expect(pick).to be_nil
  end
  first_image = all("#film_#{@film.id}_#{attr == 'rating' ? 'stars' : 'dots'} img")[1]
  first_image.click
  find("#film_#{@film.id}_progress.obscured") # wait for ajax
end

Then /^I should see a list of all the films(| sorted by country)$/ do |sorting|
  sorted_film_ids = if sorting
    @festival.films.to_a.sort_by {|f| [f.countries.present? ? country_names(f.countries) \
                                                            : 'ZZZZZZZ', f.sort_name] }
  else
    @festival.films.to_a.sort_by {|f| f.name }
  end.map {|f| f.id }
  film_list_ids = page.all("table#picks tbody tr").map {|e| e['id'] && e['id'].gsub('film_', '').to_i }.compact
  expect(film_list_ids).to eq(sorted_film_ids)
end

Then /^I should see an alert saying '([^\']+)'$/ do |msg|
  expect(page.evaluate_script('window.alert_message')).to match(Regexp.new(msg))
end

Then /^I should not see an alert$/ do
  expect(page.evaluate_script('window.alert_message')).to be_nil
end

Given /^the film (priority|rating) should be set$/ do |attr|
  pick = @festival.picks.where(user_id: @user.id, film_id: @film.id).first
  expect(pick.send(attr)).to eq((attr == 'rating') ? 1 : 0)
end
