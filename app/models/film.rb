class Film < ActiveRecord::Base
  belongs_to :festival, touch: true
  has_many :screenings, dependent: :destroy
  has_many :picks, dependent: :destroy

  attr_accessible :countries, :description, :duration, :name, :page, :url_fragment

  validates :duration, :festival_id, :name, presence: true

  scope :by_name, lambda { order(:name) }

  def page_number
    page.to_i if page.present?
  end
end
