
When /^I visit the locations page$/ do
  visit admin_locations_path
end

Then /^I should see the locations and venues listed in groups$/ do
  expect(page.all(".place h2").map(&:text).sort).to eq(Location.all.map(&:place).uniq.sort)

  page.all(".place").each do |place|
    locations = Location.where(place: place.text)
    locations.each do |location|
      location_li = place.find("li#location_#{location.id}")
      expect(location_li).to have_content(location.name)
      location.venues.each do |venue|
        expect(location_li.find("li#venue_#{venue.id} h4")).to have_content(venue.name)
      end
    end
  end
end
