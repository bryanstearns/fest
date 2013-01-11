class Venue < ActiveRecord::Base
  belongs_to :location, touch: true
  attr_accessible :abbreviation, :name

  validates :abbreviation, :location_id, :name, presence: true
end
