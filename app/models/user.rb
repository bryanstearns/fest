class User < ActiveRecord::Base
  devise :confirmable, :database_authenticatable, :lockable,
         :registerable, :recoverable, :rememberable, :trackable,
         :validatable

  VALID_PREFERENCES = %w[hide_instructions unsubscribed bounced]
  store_accessor :preferences, *VALID_PREFERENCES.map(&:to_sym)

  include BlockedEmailAddressChecks

  has_many :activity, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :travel_intervals, dependent: :destroy
  has_many :questions, dependent: :nullify
  has_many :picks, dependent: :destroy do
    def find_or_initialize_for(film_id)
      Pick.includes(screening: :festival, film: :festival)\
          .find_or_initialize_by(user_id: proxy_association.owner.id,
                                 film_id: film_id).tap do |result|
        result.festival ||= Film.find(film_id).festival
      end
    end
  end
  has_many :screenings, through: :picks

  before_save :set_calendar_token
  before_create :set_welcomed_at

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

  def mailable?
    confirmed? && !unsubscribed? && !bounced?
  end

  def confirm!
    if super
      self.bounced = nil
      save!
    end
  end

  def subscription_for(festival_id, options={})
    festival_id = festival_id.id unless festival_id.is_a? Integer
    rel = subscriptions.where(festival_id: festival_id)
    if options[:create]
      rel.first_or_create!(festival_id: festival_id)
    else
      rel.first
    end
  end

  def default_festival
    festival = picks.includes(:festival).order('picks.updated_at').last.try(:festival)
    festival if festival && festival.is_latest_in_group?
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

  def set_calendar_token
    self.calendar_token ||= SecureRandom.hex(4)
  end

  def news(limit=nil)
    Announcement.published_since(welcomed_at).limit(nil)
  end

  def hasnt_seen?(announcement)
    announcement.try(:published?) && (announcement.published_at > welcomed_at)
  end

  def set_welcomed_at
    self.welcomed_at ||= Time.current
  end

  def news_delivered!(time = Time.current)
    self.welcomed_at = time
    self.save!
  end
end
