desc "Dump a festival to a CSV"
task :csv => :environment do
  require 'csv'
  extend ApplicationHelper

  festival = Festival.where(slug: ENV['FESTIVAL']) if ENV["FESTIVAL"]
  festival ||= Festival.where('ends_on >= ?', Date.today)
  festival = festival.includes(screenings: [:film, :venue]).first
  abort "Festival not found" unless festival

  csv_path = ENV['CSV']
  abort "You forgot CSV=not found" unless csv_path
  CSV.open(csv_path, 'wb') do |csv|
    csv << ["#{festival.name} #{festival.starts_on.year}, #{festival.place}"]
    csv << ["As of #{festival.revised_at.strftime("%m/%d/%Y %H:%M %p")}"]
    csv << []
    csv << ["Date", "Start", "End", "Minutes", "Venue", "Film", "Countries"]

    festival.screenings.each do |screening|
      unless screening.press
        csv << [
          screening.starts_at.strftime("%m/%d/%Y"),
          screening.starts_at.strftime("%H:%M %p"),
          screening.ends_at.strftime("%H:%M %p"),
          screening.film.duration / 60,
          screening.venue.abbreviation,
          screening.film.name,
          country_names(screening.film.countries)
        ]
      end
    end
  end
end
