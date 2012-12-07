class Film < ActiveRecord::Base
  belongs_to :festival
  attr_accessible :countries, :description, :duration, :name, :page, :url_fragment

  validates :duration, :festival_id, :name, presence: true

  def page_number
    page.to_i if page.present?
  end
end
