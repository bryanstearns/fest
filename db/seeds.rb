# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

unless User.where(email: 'bryanstearns@gmail.com').any?
  me = User.new(name: 'Bryan Stearns', email: 'bryanstearns@gmail.com',
                password: 'sw0rdf1sh', password_confirmation: 'sw0rdf1sh')
  me.admin = true
  me.confirmed_at = Time.zone.now
  me.last_sign_in_at = me.current_sign_in_at = me.confirmed_at = Time.zone.now
  me.last_sign_in_ip = me.current_sign_in_ip = '127.0.0.1'
  me.sign_in_count = 1
  me.save!

  guest = User.new(name: 'Guest', email: 'guest@example.com',
                password: 'sw0rdf1sh', password_confirmation: 'sw0rdf1sh')
  guest.confirmed_at = Time.zone.now
  guest.last_sign_in_at = guest.current_sign_in_at = guest.confirmed_at = Time.zone.now
  guest.last_sign_in_ip = guest.current_sign_in_ip = '127.0.0.1'
  guest.sign_in_count = 1
  guest.save!
end

Festival.where(slug_group: 'example').destroy_all
Location.where('not exists (select 1 from festival_locations ' +
               'where locations.id = festival_locations.location_id)').destroy_all

starts_at = 2.days.ago.at("18:00")
ends_at = 2.days.from_now.at("22:30")

fest = \
  Festival.create!(name: 'Example International Film Festival',
                   location: "Long Name City, Longstatename",
                   slug_group: 'example',
                   starts_on: starts_at, ends_on: ends_at,
                   public: true, scheduled: true)
loc = fest.locations.create!(name: "Exampleplex")
venues = (1..3).map do |i|
  loc.venues.create!(name: "ExamplePlex #{i}", abbreviation: "EP#{i}")
end
films = [
    fest.films.create!(name: "Family Plot", duration: 120, page: 12.1),
    fest.films.create!(name: "Frenzy", duration: 116, page: 12.2),
    fest.films.create!(name: "Topaz", duration: 143, page: 12.3),
    fest.films.create!(name: "Marnie", duration: 130, page: 11.1),
    fest.films.create!(name: "The Birds", duration: 119, page: 10.1),
    fest.films.create!(name: "Psycho", duration: 109, page: 8.1),
    fest.films.create!(name: "North by Northwest", duration: 136, page: 9.1),
    fest.films.create!(name: "Vertigo", duration: 128, page: 9.2),
    fest.films.create!(name: "The Wrong Man", duration: 105, page: 10.2),
    fest.films.create!(name: "Blackmail", duration: 84, page: 10.3)
]
t = starts_at
while t < ends_at
  puts "Starting #{t.to_date}"
  limit = t.at(ends_at)
  venues.each_with_index do |venue, i|
    tv = t + (5 * rand(3)).minutes
    puts "  #{i}: Venue #{venue.name}, starting at #{tv}"
    while tv < limit
      film = films.sample
      puts "    Added #{film.name} at #{I18n.l tv, format: :mdy_hms}"
      Screening.create!(film: film, venue: venue, starts_at: tv,
                        press: tv.to_date == starts_at.to_date)
      tv += (film.duration + 10).minutes
    end
  end
  t = (t + 1.day).at(starts_at)
end
