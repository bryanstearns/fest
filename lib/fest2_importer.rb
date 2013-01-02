module Fest2Importer
  module Importable
    extend ActiveSupport::Concern
    included do
      establish_connection 'fest2_snapshot'
    end

    def import
      raise NotImplementedError, "#{self.class.name} needs to implement #import!"
    end

    module ClassMethods
      def import_all
        order(:id).all.each {|instance| instance.import }
      end
    end
  end

  module NameFixes
    def fix_name(name)
      name = 'Fields Ballroom' if name == 'Field\'s Ballroom'
      name = 'Newmark Theatre' if name == 'Newmark Theater'
      name = 'California Theatre' if name == 'California Theater'
      name
    end

    def fixed_name?(name)
      ['Field\'s Ballroom', 'Newmark Theater',
       'California Theater'].include?(name)
    end
  end

  class ImportableModel < ActiveRecord::Base
    self.abstract_class = true
    include Fest2Importer::Importable
    extend NameFixes
    include NameFixes
  end

  class Location < ImportableModel
    def self.import_all
      Location.all.map(&:name).uniq.each do |name|
        next if fixed_name?(name)
        Rails.logger.info "Creating Location: #{name}"
        ::Location.create!(name: name)
      end
    end
  end

  class Venue < ImportableModel
    belongs_to :location

    def self.import_all
      locations = ::Location.all.inject({}) {|h, l| h[l.name] = l; h }
      venues = {}
      Venue.all.each do |venue|
        venue_name = fix_name(venue.name)
        location_name = fix_name(venue.location.name)
        venues[[location_name, venue_name]] ||= begin
          location = locations[location_name]
          unless location
            debugger
            raise "Couldn't find imported location #{location_name} for old venue #{venue.inspect}"
          end
          if location.venues.where(name: venue_name).any?
            Rails.logger.info "Venue exists: #{venue_name}, #{venue.abbrev} in Location: #{location.name}"
            nil # already exists
          else
            Rails.logger.info "Creating Venue: #{venue_name}, #{venue.abbrev} in Location: #{location.name}"
            location.venues.create!(
              name: venue_name,
              abbreviation: venue.abbrev)
          end
        end
      end
    end
  end

  class Festival < ImportableModel
    def import
      Rails.logger.info "Creating festival #{slug}"
      f = ::Festival.create!({
          name: name,
          slug_group: slug_group,
          main_url: url,
          public: public,
          scheduled: scheduled,
          location: location,
          starts_on: starts,
          ends_on: ends
        },
        without_protection: true)
      Location.find_all_by_festival_id(id).each do |location|
        location_name = fix_name(location.name)
        Rails.logger.info "Subscribing #{f.slug} to location #{location_name}"
        f.locations << ::Location.find_by_name(location_name)
      end
    end
  end

  class Film < ImportableModel
    belongs_to :festival

    def attributes_to_copy
      attributes.except(*%w[id festival_id updated_at created_at duration])\
                .merge(duration: duration / 60)
    end

    def new_festival
      @@festivals ||= ::Festival.all.inject({}) do |h, festival|
        h[festival.slug] = festival
        h
      end
      @@festivals[festival.slug]
    end

    def import
      new_festival.films.create(attributes_to_copy,
                                without_protection: true)
    end
  end

  class Screening < ImportableModel
    belongs_to :festival
    belongs_to :film
    belongs_to :venue
    belongs_to :location

    def attributes_to_copy
      {
          film: new_film,
          starts_at: starts,
          ends_at: ends,
          press: press,
          location: new_venue.location,
          venue: new_venue,
      }
    end

    def new_film
      @@films ||= ::Film.includes(:festival)\
          .all.inject({}) do |h, film|
        festival = film.festival
        h[[film.festival.slug, film.name]] = film
        h
      end
      @@films[[self.festival.slug, self.film.name]]
    end

    def new_venue
      @@venues ||= ::Venue.includes(:location).all.inject({}) do |h, venue|
        h[fix_name(venue.name)] = venue
        h
      end
      @@venues[fix_name(self.venue.name)]
    end
    def import
      new_film.festival.screenings.create!(attributes_to_copy,
                                           without_protection: true)
    end
  end

  def self.import
    Rails.logger.info "Importing Fest2 data..."
    [Location, Venue, Festival, Film, Screening].each do |klass|
      klass.import_all
    end
    Rails.logger.info "Done importing Fest2 data..."
  end
end
