
When /^I visit the home page$/ do
  visit welcome_path
end

When /^I visit the maintenance page$/ do
  visit maintenance_path
end

Then /^I should see a welcome message$/ do
  page.should have_content("Get more from your film festival experience!")
end

Then /^I should see that we're closed$/ do
  page.should have_content("Get more from your film festival experience!")
end
