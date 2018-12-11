# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'factory_bot_rails'

if !Rails.env.production?
  admin = User.where(email: 'admin@example.com').first
  unless admin
    admin = User.new(name: 'Admin', email: 'admin@example.com',
                  password: 'sw0rdf1sh', password_confirmation: 'sw0rdf1sh')
    admin.admin = true
    admin.confirmed_at = Time.zone.now
    admin.last_sign_in_at = admin.current_sign_in_at = admin.confirmed_at = Time.zone.now
    admin.last_sign_in_ip = admin.current_sign_in_ip = '127.0.0.1'
    admin.sign_in_count = 1
    admin.save!
  end

  guest = User.where(email: 'guest@example.com').first
  unless guest
    guest = User.new(name: 'Guest', email: 'guest@example.com',
                  password: 'sw0rdf1sh', password_confirmation: 'sw0rdf1sh')
    guest.confirmed_at = Time.zone.now
    guest.last_sign_in_at = guest.current_sign_in_at = guest.confirmed_at = Time.zone.now
    guest.last_sign_in_ip = guest.current_sign_in_ip = '127.0.0.1'
    guest.sign_in_count = 1
    guest.save!
  end

  Festival.where(slug_group: 'example').destroy_all
  Location.unused.destroy_all if Location.any?

  example_fest = FactoryBot.create(:festival, :with_films_and_screenings,
                                   name: "Example Festival",
                                   slug_group: 'example',
                                   day_count: 2, press: true,
                                   place: "Long Name City, Longstatename")
  example_fest.films.each do |film|
    priority = Pick::PRIORITY_HINTS.keys[film.duration.to_minutes % Pick::PRIORITY_HINTS.count]
    admin.picks.create!(film: film, priority: priority)
  end

  FactoryBot.create(:festival, :past,
                    name: "Example Festival", slug_group: 'example',
                    day_count: 2,
                    place: "Long Name City, Longstatename")
end
