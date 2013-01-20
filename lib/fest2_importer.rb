require 'securerandom'

module Fest2Importer
  module Importable
    extend ActiveSupport::Concern
    included do
      establish_connection 'fest2_snapshot'
    end

    def import
      raise NotImplementedError, "#{self.class.name} needs to implement #import!"
    end

    def self.fake_slug
      @@fake_slug ||= nil
    end
    def self.fake_slug=(x)
      @@fake_slug = x
    end

    def self.time_offset
      @@time_offset ||= 0.seconds
    end
    def self.time_offset=(t)
      @@time_offset = t
    end

    module ClassMethods
      def import_all
        order(:id).all.each {|instance| instance.import }
      end

      def seen?(key)
        @seen ||= Set.new
        @seen.include?(key).tap { @seen << key }
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

    def bad_name?(name)
      ['Field\'s Ballroom', 'Newmark Theater',
       'California Theater'].include?(name)
    end
  end

  module MapsToNew
    extend ActiveSupport::Concern
    module ClassMethods
      # Make a "new_(thing)" method that finds corresponding new instances of
      # related models
      def new_cache
        @@cache ||= {}
      end

      def maps_to_new(klass, options={})
        thing_name = klass.name.underscore
        things_sym = klass.name.pluralize.underscore.to_sym
        define_method("new_#{thing_name}") do
          self.class.new_cache[things_sym] ||= begin
            new_things = case options[:includes]
            when nil
              klass
            when Array
              klass.includes(*options[:includes])
            else
              klass.includes(options[:includes])
            end
            new_things.all.map_by do |new_thing|
              if block_given?
                debugger unless new_thing
                yield new_thing
              else
                new_thing.id
              end
            end
          end
          key = block_given? ? yield(self.send(thing_name)) : id
          key && self.class.new_cache[things_sym][key]
        end
      end

      def clear_cache(*thing_syms)
        if thing_syms.empty?
          @@cache = {}
        else
          thing_syms.each {|k| @@cache.delete(k) }
        end
      end
    end
  end

  class ImportableModel < ActiveRecord::Base
    self.abstract_class = true
    include Fest2Importer::Importable
    extend NameFixes
    include NameFixes
    include MapsToNew

    def fixed_name
      @fixed_name ||= bad_name?(name) ? fix_name(name) : name
    end
  end

  class Location < ImportableModel
    def import
      return if Location.seen?(fixed_name)
      Rails.logger.info "Creating Location: #{fixed_name}"
      ::Location.create!({ name: fixed_name,
                           created_at: created_at,
                           updated_at: updated_at },
                         without_protection: true)
    end
  end

  class Venue < ImportableModel
    belongs_to :location
    maps_to_new(::Location) {|location| fix_name(location.name) }

    def import
      return if Venue.seen?([fix_name(location.name), fixed_name])
      new_location.venues.create!({
                                    name: fixed_name,
                                    abbreviation: abbrev,
                                    created_at: created_at,
                                    updated_at: updated_at
                                  },
                                  without_protection: true)
    end
  end

  class Festival < ImportableModel
    has_many :films
    has_many :screenings

    def attributes_to_copy
      {
        name: name,
        slug_group: slug_group,
        main_url: url,
        public: public,
        scheduled: scheduled,
        location: location,
        starts_on: starts + Importable::time_offset,
        ends_on: ends + Importable::time_offset,
        revised_at: revised_at? ? (revised_at + Importable::time_offset) : nil,
        created_at: created_at + Importable::time_offset,
        updated_at: updated_at + Importable::time_offset
      }
    end

    def import
      Rails.logger.info "Creating festival #{slug}"
      f = ::Festival.create!(attributes_to_copy,
                             without_protection: true)
      Location.where(festival_id: id).each do |location|
        location_name = fix_name(location.name)
        Rails.logger.info "Subscribing #{f.slug} to location #{location_name}"
        f.locations << ::Location.where(name: location_name).first
      end
    end

    def slug
      Importable::fake_slug || read_attribute(:slug)
    end
  end

  class Film < ImportableModel
    belongs_to :festival

    maps_to_new(::Festival) {|festival| festival.slug }

    def attributes_to_copy
      attributes.except(*%w[id festival_id updated_at created_at])\
                .merge(created_at: created_at + Importable::time_offset,
                       updated_at: updated_at + Importable::time_offset)
    end

    def import
      new_festival.films.create!(attributes_to_copy,
                                 without_protection: true) \
        unless new_festival.films.where(name: name).exists?
    end
  end

  class Screening < ImportableModel
    belongs_to :festival
    belongs_to :film
    belongs_to :venue
    belongs_to :location

    maps_to_new(::Film, includes: :festival) {|film| [film.festival.slug, film.name]}
    maps_to_new(::Venue, includes: :location) {|venue| fix_name(venue.name) }

    def attributes_to_copy
      {
          film: new_film,
          starts_at: starts + Importable::time_offset,
          ends_at: ends + Importable::time_offset,
          press: press,
          location: new_venue.location,
          venue: new_venue,
          created_at: created_at + Importable::time_offset,
          updated_at: updated_at + Importable::time_offset
      }
    end

    def import
      new_film.festival.screenings.create!(attributes_to_copy,
                                           without_protection: true)
    end

    # Alias these attributes to their new-world names
    def starts_at; starts end
    def ends_at; ends end
  end

  class User < ImportableModel

    def attributes_to_copy
      {
          name: username,
          email: email,
          admin: admin,
          password: random_password,
          password_confirmation: random_password,
          confirmation_sent_at: created_at,
          confirmed_at: created_at,
          created_at: created_at,
          updated_at: updated_at
          # TODO: mail_opt_out!
      }
    end

    def import
      unless User.seen?(email)
        user = ::User.create!(attributes_to_copy,
                              without_protection: true)
        if ENV['FF_EMAIL'] && ENV['FF_PSWD'] && ENV['FF_EMAIL'] == user.email
          user.update_attribute(:encrypted_password, ENV['FF_PSWD'])
        end
      end
    end

    def random_password
      @random_password ||= SecureRandom.uuid
    end
  end

  class Pick < ImportableModel
    belongs_to :festival
    belongs_to :film
    belongs_to :screening
    belongs_to :user

    maps_to_new(::Screening, includes: { film: :festival }) \
      {|screening| screening && [screening.film.festival.slug, screening.film.name, screening.starts_at] }
    maps_to_new(::Film, includes: :festival) \
      {|film| [film.festival.slug, film.name] }
    maps_to_new(::User) {|user| user.email.downcase }

    def attributes_to_copy
      {
          user: new_user,
          screening: new_screening,
          film: new_film,
          festival: new_film.festival,
          priority: priority,
          rating: rating,
          created_at: created_at,
          updated_at: updated_at
      }
    end
    def import
      ::Pick.create!(attributes_to_copy,
                     without_protection: true)
    end
  end

  def self.import
    Rails.logger.info "Importing Fest2 data..."
    [Location, Venue, Festival, Film, Screening, User, Pick].each do |klass|
      klass.import_all
    end

    # Import last year's PIFF as though it's this year's
    Film.clear_cache
    Screening.clear_cache
    Importable::time_offset = 364.days
    Importable::fake_slug = 'piff_2013'
    piff12 = Festival.where(slug: 'piff_2012').first
    piff12.import
    piff12.films.find_each {|f| f.import }
    piff12.screenings.find_each {|s| s.import }
    Importable::time_offset = 0.seconds
    Importable::fake_slug = nil

    Rails.logger.info "Done importing Fest2 data..."
  end
end
