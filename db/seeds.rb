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

example = \
  Festival.create!(name: 'Example International Film Festival',
                   location: "Long Name City, Longstatename",
                   slug_group: 'example',
                   starts_on: 2.days.ago, ends_on: 2.days.from_now,
                   public: true, scheduled: true)
loc = example.locations.create!(name: "Exampleplex")
(1..3).each do |i|
  loc.venues.create!(name: "ExamplePlex #{i}", abbreviation: "EP#{i}")
end
example.films.create!(name: "Vertigo", duration: 90, page: 12.1)
example.films.create!(name: "Psycho", duration: 100, page: 8.1)
example.films.create!(name: "The Birds", duration: 110, page: 10.1)
example.films.create!(name: "Blackmail", duration: 80, page: 10.2)
