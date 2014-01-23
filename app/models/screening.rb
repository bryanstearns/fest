class Screening < ActiveRecord::Base
  belongs_to :festival
  belongs_to :film, touch: true
  belongs_to :location
  belongs_to :venue
  has_many :picks, dependent: :nullify

  attr_accessible :ends_at, :festival, :film, :location, :press, :starts_at,
                  :venue_id

  validates :film_id, :venue_id, :starts_at, presence: true
  validates :ends_at, presence: true,
            if: ->(x) { x.film_id? && x.starts_at? }
  validates :festival_id, presence: true, if: :film_id?
  validates :location_id, presence: true, if: :venue_id?

  before_validation :assign_denormalized_ids, :assign_ends_at

  default_scope order(:starts_at, :id)

  scope :on, ->(date) {
    t = date.to_date.to_time_in_current_zone
    where(['(screenings.starts_at >= ? and screenings.ends_at <= ?)',
           t.beginning_of_day, t.end_of_day])
  }
  scope :starting_after, ->(time) {
    where('screenings.starts_at > ?', time)
  }
  scope :with_press, ->(with_press) {
    with_press ? scoped : where('screenings.press = ?', false)
  }
  scope :for_calendar, -> {
    where('screenings.starts_at > ? and screenings.starts_at < ?',
          6.months.ago, 6.months.from_now)
  }

  delegate :name, :abbreviation, to: :venue, prefix: true
  delegate :name, :short_name, :countries, to: :film

  def duration
    (ends_at - starts_at).to_i rescue film.try(:duration)
  end

  def future?
    starts_at > Time.current
  end

  def conflicts_with?(other, user_id)
    # easy tests first:
    return false if
        (self == other) ||
        (venue_id == other.venue_id) ||
        (festival_id != other.festival_id) ||
        ((starts_at - other.ends_at) > TravelInterval::MAX_INTERVAL) ||
        ((other.starts_at - ends_at) > TravelInterval::MAX_INTERVAL)

    # couldn't rule out easily - do the harder tests.
    if starts_at < other.starts_at # we go from this to the other
      (other.starts_at - ends_at) < TravelInterval.between(location_id, other.location_id, user_id)
    else # we go from there to here
      (starts_at - other.ends_at) < TravelInterval.between(other.location_id, location_id, user_id)
    end
  end

protected
  def assign_denormalized_ids
    self.festival_id = film.festival_id unless festival_id || !film
    self.location_id = venue.location_id unless location_id || !venue
  end

  def assign_ends_at
    self.ends_at = (starts_at + film.duration) if starts_at && film
  end
end
