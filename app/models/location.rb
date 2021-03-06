class Location < ApplicationRecord
  has_many :festival_locations
  has_many :festivals, through: :festival_locations
  has_many :venues, dependent: :destroy
  has_many :travel_intervals_from, class_name: 'TravelInterval',
           foreign_key: :from_location_id, dependent: :destroy
  has_many :travel_intervals_to, class_name: 'TravelInterval',
           foreign_key: :to_location_id, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :place }
  validates :place, :parking_minutes, presence: true
  validates :parking_minutes, inclusion: 1..60

  scope :unused, -> { where('not exists (select 1 from festival_locations ' +
                            'where locations.id = festival_locations.location_id)') }

  def label
    "#{name} (#{place})"
  end

  def googleable_address
    read_attribute(:address).presence || "#{name}, #{place}"
  end
end
