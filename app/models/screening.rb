class Screening < ActiveRecord::Base
  # Screenings separated by this much can't conflict for anyone
  MAX_TRAVEL_TIME = 2.hours

  # Until we do travel time for real, use this
  TRAVEL_TIME = 15.minutes

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

  default_scope order(:starts_at)

  scope :on, ->(date) {
    t = date.to_date.to_time_in_current_zone
    where(['(screenings.starts_at >= ? and screenings.ends_at <= ?)',
           t.beginning_of_day, t.end_of_day])
  }
  scope :starting_after, ->(time) {
    where('screenings.starts_at > ?', time)
  }

  delegate :name, to: :venue, prefix: true
  delegate :name, :countries, to: :film

  def duration
    (ends_at - starts_at).to_i rescue film.try(:duration)
  end

  def conflicts_with?(other)
    return false if
        (self == other) ||
        (venue_id == other.venue_id) ||
        (festival_id != other.festival_id)
    if starts_at < other.starts_at # we go from this to the other
      (other.starts_at - ends_at) < TRAVEL_TIME
    else # we go from there to here
      (starts_at - other.ends_at) < TRAVEL_TIME
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
