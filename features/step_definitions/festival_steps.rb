When /^there are three festivals in two groups$/ do
  @grouped_festivals_with_dates = {
    'piff' => {
      'Mar 2 - 4, 2011' => create(:festival, :slug_group => 'piff', :starts_on => '2011-03-02',
                                  :day_count => 3),
      'Mar 1 - 3, 2012' => create(:festival, :slug_group => 'piff', :starts_on => '2012-03-01',
                                  :day_count => 3),
    },
    'reel' => {
      'Jun 30 - Jul 2, 2012' => create(:festival, :slug_group => 'reel',
                                       :starts_on => '2012-06-30', :day_count => 3)
    }
  }
end

When /^I visit the festivals index page$/ do
  visit festivals_path
end

Then /^I should see the festivals listed in groups$/ do
  @grouped_festivals_with_dates.each do |slug, festivals_with_dates|
    group_element = page.find(".festival-group#group-#{slug}")
    festivals_with_dates.each do |dates, festival|
      group_element.should have_content(festival.name)
      group_element.find("#festival_#{festival.id}").text.strip.should eq(dates)
    end
  end
end

When /^I visit the festival page$/ do
  visit festival_path(@festival)
end

Then /^I should( not)? see an Edit link$/ do |notness|
  festival_nav = page.find("header.festival")
  if notness != ' not'
    festival_nav.should have_link "Edit"
  else
    festival_nav.should_not have_link "Edit"
  end
end

Then /^I should see a grid for each day of the festival$/ do
  days = page.all("table.day")
  days.should have_at_least(1).items
end

Then /^I should see the last\-revised time of the festival$/ do
  page.find("#as-of").should have_content("Festival as of ")
end
