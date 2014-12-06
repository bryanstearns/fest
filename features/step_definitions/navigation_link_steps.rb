
Then /^I should see the signed-in navigation links$/ do
  expect(page).to have_link("Sign out")
  expect(page).to_not have_link("Sign up")
  expect(page).to_not have_link("Sign in")
end

Then /^I should see the signed-out navigation links$/ do
  expect(page).to have_link("Sign up")
  expect(page).to have_link("Sign in")
  expect(page).to_not have_link("Sign out")
end

Then /^I should not see the Sign Up button$/ do
  expect(page).to_not have_button("Sign Up")
end
