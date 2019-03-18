class CombineOldBroadwayVenues < ActiveRecord::Migration[4.2]
  def up
    old_location = Location.where(place: "Portland, Oregon", name: "Regal Broadway").first
    if old_location
      new_location = Location.where(place: "Portland, Oregon", name: "Broadway").first

      old_location.venues.each do |old_venue|
        new_venue = new_location.venues.where(abbreviation: old_venue.abbreviation).first
        old_venue.screenings.each do |screening|
          screening.update_attributes(venue_id: new_venue.id)
        end
      end

      old_location.festivals.each do |festival|
        festival.locations.destroy(old_location)
        festival.locations << new_location
      end

      old_location.destroy
    end
  end
end
