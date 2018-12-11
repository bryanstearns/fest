class Venue < ApplicationRecord
  belongs_to :location, touch: true
  has_many :screenings

  validates :abbreviation, :location_id, :name, presence: true
end
