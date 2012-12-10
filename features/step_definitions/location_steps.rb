
When /^I visit the locations page$/ do
  visit locations_path
end

Then /^I should see the locations and venues listed in groups$/ do
  locations_list = page.find("#locations")
  location_item = locations_list.find("li#location_#{@location.id}")
  location_item.find("h2").should have_content(@location.name)
  @location.venues.each do |v|
    location_item.find("li#venue_#{v.id} h3").should have_content(v.name)
  end
end
