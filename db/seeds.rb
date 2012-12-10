# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'factory_girl_rails'

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
Location.unused.destroy_all

FactoryGirl.create(:festival, :with_films_and_screenings,
                   name: "Example Festival", slug_group: 'example',
                   day_count: 4, press: true,
                   location: "Long Name City, Longstatename")

FactoryGirl.create(:festival, :past,
                   name: "Example Festival", slug_group: 'example',
                   day_count: 4,
                   location: "Long Name City, Longstatename")
