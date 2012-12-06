class Location < ActiveRecord::Base
  has_many :festival_locations
  has_many :festivals, through: :festival_locations
  has_many :venues, dependent: :destroy

  attr_accessible :name

  validates :name, presence: true, uniqueness: true
end
