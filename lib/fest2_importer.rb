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
    def self.date_offset
      time_offset / 86400
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

    def fix_email(email)
      # 'wood molding@hotmail.com' -> 'wood_molding@hotmail.com'
      email.downcase.gsub(' ', '_')
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
    has_many :subscriptions
    has_many :picks

    def attributes_to_copy
      {
        name: name,
        slug_group: slug_group,
        main_url: url,
        published: public,
        scheduled: scheduled,
        location: location,
        starts_on: starts + Importable::date_offset,
        ends_on: ends + Importable::date_offset,
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
      result = Importable::fake_slug || read_attribute(:slug)
      result = 'piff_2013' if result == 'piff'
      result
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
          email: fix_email(email),
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
      unless User.seen?(fix_email(email))
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
    maps_to_new(::User) {|user| fix_email(user.email) }

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
    def import(without_screenings = nil)
      copying_attributes = attributes_to_copy
      copying_attributes.delete(:screening) if without_screenings
      ::Pick.create!(copying_attributes,
                     without_protection: true)
    end
  end

  class Subscription < ImportableModel
    belongs_to :user
    belongs_to :festival

    maps_to_new(::Festival) {|festival| festival.slug }
    maps_to_new(::User) {|user| fix_email(user.email) }

    def attributes_to_copy
      {
          festival: new_festival,
          user: new_user,
          show_press: show_press,
          created_at: created_at,
          updated_at: updated_at
      }
    end
    def import
      begin
        ::Subscription.create!(attributes_to_copy,
                               without_protection: true)
      rescue
        raise if user.email !~ /molding/
      end
    end
  end

  def self.drop_bad_accounts
    bad_domains = [
        # Had a run of spammers trying to abuse the old site.
        "126.com", "163.com", "21cn.com", "believesex.com", "brightadult.com",
        "easystreet.net_expired", "example.com", "eyou.com",
        "feeladult.com", "ij.net", "kissadulttoys.com", "linkadulttoys.com",
        "loginadulttoys.com", "mail15.com", "mail333.com", "ngs.ru",
        "oncesex.com", "onsaleadult.com", "pickadulttoys.com", "tom.com",
        "yeah.net", "zpzchina.com"
    ]
    unsubscribed_users = [
        # These are patterns so that I don't put actual users' emails on github
        /.*\@mvmft\.com/,
        /k.*1968/,
        /spur.*net/
    ]
    good_domains = [ 'nwfilm.org' ]
    ::User.find_each do |user|
      domain = user.email.split('@').last
      pick_count = user.picks.count
      festivals = user.picks.map {|p| p.festival.slug}.uniq
      email = user.email.strip
      if unsubscribed_users.any? {|p| p =~ email }
        Rails.logger.info "Destroying unsubscribed user: #{user.name}, #{email}"
        user.destroy
      elsif bad_domains.include?(domain) || email.index(' ')
        Rails.logger.info "Destroying bad_domain user: #{user.name}, #{email}, #{pick_count} in #{festivals.join(', ')}"
        user.destroy
      elsif pick_count < 2 and !good_domains.include?(domain)
        Rails.logger.info "Destroying no-pick user: #{user.name}, #{email}, #{pick_count}"
        user.destroy
      else
        Rails.logger.info "Keeping user: #{user.name}, #{email}, #{pick_count} in #{festivals.join(', ')}"
      end
    end
  end

  def self.import
    Rails.logger.info "Importing Fest2 data..."
    [Location, Venue, Festival, Film, Screening, User, Pick].each do |klass|
      klass.import_all
    end

    if false
      # Import last year's PIFF as though it's this year's
      Film.clear_cache
      Screening.clear_cache
      Subscription.clear_cache
      Pick.clear_cache
      piff12 = Festival.where(slug: 'piff_2012').first
      Importable::time_offset = Date.tomorrow.to_time -
          piff12.screenings.order(:starts).first.starts
      Importable::fake_slug = 'piff_2013'
      piff12.import
      piff12.films.find_each {|f| f.import }
      piff12.screenings.find_each {|s| s.import }
      piff12.subscriptions.find_each {|s| s.import }
      piff12.picks.find_each {|p| p.import(:without_screenings) }
      Importable::time_offset = 0.seconds
      Importable::fake_slug = nil
    end

    Rails.logger.info "Dropping bad accounts..."
    drop_bad_accounts

    Rails.logger.info "Done importing Fest2 data..."
  end
end unless ENV['TRAVIS']
