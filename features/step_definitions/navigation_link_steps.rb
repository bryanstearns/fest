
Then /^I should see the signed-in navigation links$/ do
  page.should have_link("Sign out")
  page.should_not have_link("Sign up")
  page.should_not have_link("Sign in")
end

Then /^I should see the signed-out navigation links$/ do
  page.should have_link("Sign up")
  page.should have_link("Sign in")
  page.should_not have_link("Sign out")
end

Then /^I should not see the Sign Up button$/ do
  page.should_not have_button("Sign Up")
end
