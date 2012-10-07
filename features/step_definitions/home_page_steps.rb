
When /^I visit the home page$/ do
  visit root_path
end

Then /^I should see a welcome message$/ do
  page.should have_content("Get more from your film festival experience!")
end
