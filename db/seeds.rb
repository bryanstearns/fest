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
end

Festival.where(slug_group: 'example').delete_all
Festival.create!(name: 'Example International Film Festival',
                 location: "Long Name City, Longstatename",
                 slug_group: 'example',
                 starts_on: 2.days.ago, ends_on: 2.days.from_now,
                 public: true, scheduled: true)
