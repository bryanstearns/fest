class User < ActiveRecord::Base
  devise :confirmable, :database_authenticatable, :lockable,
         :registerable, :recoverable, :rememberable, :trackable,
         :validatable

  VALID_PREFERENCES = %w[hide_instructions]
  serialize :preferences, ActiveRecord::Coders::Hstore

  include BlockedEmailAddressChecks

  has_many :subscriptions, dependent: :destroy
  has_many :travel_intervals, dependent: :destroy
  has_many :questions, dependent: :nullify
  has_many :picks, dependent: :destroy do
    def find_or_initialize_for(film_id)
      Pick.includes(screening: :festival, film: :festival)\
          .find_or_initialize_by_user_id_and_film_id(proxy_association.owner.id,
                                                     film_id).tap do |result|
        result.festival ||= Film.find(film_id).festival
      end
    end
  end

  attr_accessible :name, :email, :password, :password_confirmation, :remember_me
  attr_accessible :admin, :name, :email, :ffff, :password,
                  :password_confirmation, :remember_me, as: :admin

  validates :name, :presence => true

  def self.valid_preference?(name)
    VALID_PREFERENCES.include?(name.to_s)
  end

  VALID_PREFERENCES.each do |pref|
    define_method(pref) do
      preferences[pref.to_s]
    end
    alias_method "#{pref}?".to_sym, pref.to_sym
    define_method("#{pref}=".to_sym) do |new_value|
      if preferences[pref.to_s] != new_value
        if new_value && new_value.to_s != '0'
          preferences[pref.to_s] = new_value
        else
          preferences.delete(pref.to_s)
        end
        save!
      end
      new_value
    end
  end

  def subscription_for(festival_id, options={})
    festival_id = festival_id.id unless festival_id.is_a? Integer
    rel = subscriptions.where(festival_id: festival_id)
    if options[:create]
      rel.first_or_create!({ festival_id: festival_id },
                           as: :subscription_creator)
    else
      rel.first
    end
  end

  def can_see?(screening, subscription=nil)
    subscription ||= subscription_for(screening.festival_id)
    subscription ? subscription.can_see?(screening) : !screening.press
  end

  def has_screenings_for?(festival)
    picks.where(['festival_id = ? and screening_id is not null', festival.id]).any?
  end

  def has_priorities_for?(festival)
    picks.where(['festival_id = ? and priority is not null', festival.id]).any?
  end

  def has_ratings_for?(festival)
    picks.rated.where('festival_id = ?', festival.id).any?
  end
end
