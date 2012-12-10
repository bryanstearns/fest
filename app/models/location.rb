class Location < ActiveRecord::Base
  has_many :festival_locations
  has_many :festivals, through: :festival_locations
  has_many :venues, dependent: :destroy

  attr_accessible :name

  validates :name, presence: true, uniqueness: true

  scope :unused, where('not exists (select 1 from festival_locations ' +
                       'where locations.id = festival_locations.location_id)')
end
