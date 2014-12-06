
When /^(?:the )?(\S+) (?:is|are) (dis|en)abled$/ do |switch, state|
  set_enabled_value(switch.to_sym, (state == 'en'))
  true
end

When /^I visit a page requiring authentication$/ do
  visit '/users/edit'
end

Then /^I should be told that we're closed$/ do
  expect(page).to have_content("Festival Fanatic is on vacation")
end

Then /^I should be told that signins are off$/ do
  expect(page).to have_content("signing in is temporarily unavailable")
end

Then /^I should be told to try to sign up another time$/ do
  expect(page).to have_content("No new sign ups for now")
end

Then /^I should see the home page$/ do
  expect(page).to have_content("Festival Fanatic can help you see more of the movies you want to see")
end

Then /^the HTTP status should be (\d+)$/ do |status|
  expect(page.status_code).to eq(status.to_i)
end
