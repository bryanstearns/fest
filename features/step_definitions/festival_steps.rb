
Given(/^I have scheduled at least one film$/) do
  create(:pick, user: @user, festival: @festival,
                screening: @festival.screenings.first)
end

When(/^I visit the calendar link$/) do
  calendar_url = page.find("#calendar_url").text
  visit calendar_url
end

When /^there are three festivals in two groups$/ do
  @grouped_festivals_with_dates = {
    'piff' => {
      'March 2 - 4, 2011' =>
          create(:festival, :slug_group => 'piff', :starts_on => '2011-03-02',
                 :day_count => 3),
      'March 1 - 3, 2012' =>
          create(:festival, :slug_group => 'piff', :starts_on => '2012-03-01',
                 :day_count => 3),
    },
    'reel' => {
      'June 30 - July 2, 2012' =>
          create(:festival, :slug_group => 'reel',
                 :starts_on => '2012-06-30', :day_count => 3)
    }
  }
end

When /^I visit the festivals index page$/ do
  visit festivals_path
end

Then(/^I should download a calendar with my films$/) do
  expect(page.body).to have_content("BEGIN:VCALENDAR")
end

Then /^I should see the festivals listed in groups$/ do
  @grouped_festivals_with_dates.each do |slug, festivals_with_dates|
    group_element = page.find(".festival-group#group-#{slug}")
    festivals_with_dates.each do |dates, festival|
      expect(group_element).to have_content(festival.name)
      expect(group_element.find("#festival_#{festival.id}").text.strip).to eq(dates)
    end
  end
end

When /^I visit the festival page$/ do
  visit festival_path(@festival)
end

Then /^I should( not)? see an Edit link$/ do |notness|
  festival_nav = page.find("header.festival")
  if notness != ' not'
    expect(festival_nav).to have_link "Edit"
  else
    expect(festival_nav).to_not have_link "Edit"
  end
end

Then /^I should see a grid for each day of the festival$/ do
  days = page.all("table.day")
  expect(days).to have_at_least(1).items
end

Then /^I should see the last\-revised time of the festival$/ do
  expect(page.find("#as-of")).to have_content("Festival as of ")
end
