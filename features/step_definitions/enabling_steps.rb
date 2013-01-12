
When /^(?:the )?(\S+) (?:is|are) (dis|en)abled$/ do |switch, state|
  set_enabled_value(switch.to_sym, (state == 'en'))
end

Then /^I should be told that we're closed$/ do
  page.should have_content("Festival Fanatic is on vacation")
end

Then /^the HTTP status should be (\d+)$/ do |status|
  page.status_code.should eq(status.to_i)
end
