class Screening < ActiveRecord::Base
  belongs_to :festival
  belongs_to :film
  belongs_to :location
  belongs_to :venue

  attr_accessible :ends_at, :festival, :film, :location, :press, :starts_at,
                  :venue_id

  validates :film_id, :venue_id, :starts_at, presence: true
  validates :ends_at, presence: true,
            if: lambda {|x| x.film_id? && x.starts_at? }
  validates :festival_id, presence: true, if: :film_id?
  validates :location_id, presence: true, if: :venue_id?

  before_validation :assign_denormalized_ids, :assign_ends_at

protected
  def assign_denormalized_ids
    self.festival_id = film.festival_id unless festival_id || !film
    self.location_id = venue.location_id unless location_id || !venue
  end

  def assign_ends_at
    self.ends_at = (starts_at + film.duration.minutes) if starts_at && film
  end
end
