
def call_to_action_banner
  page.find("div#calltoaction")
end

When /^(?:the )?(\S+) (?:is|are) (dis|en)abled$/ do |switch, state|
  set_enabled_value(switch.to_sym, (state == 'en'))
  true
end

When /^I visit a page requiring authentication$/ do
  visit '/users/edit'
end

Then(/^I should see the festival "(.*?)"$/) do |arg1|
  expect(call_to_action_banner.find("h4")).to have_content(Regexp.new(arg1, Regexp::IGNORECASE))
  expect(call_to_action_banner.find("h2")).to have_content(/Festival /)
end

Then(/^I should be able to get started$/) do
  expect(call_to_action_banner).to have_content("Get Started")
end

Then(/^I should not be able to get started$/) do
  expect(call_to_action_banner).to_not have_content("Get Started")
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
