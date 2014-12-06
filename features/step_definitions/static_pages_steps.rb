
When /^I visit the home page$/ do
  visit welcome_path
end

When /^I visit the maintenance page$/ do
  visit maintenance_path
end

Then /^I should see a welcome message$/ do
  expect(page).to have_content("Get more from your film festival experience!")
end

Then /^I should see that we're closed$/ do
  expect(page).to have_content("Get more from your film festival experience!")
end
