class Festival < ActiveRecord::Base
  has_many :festival_locations, dependent: :destroy
  has_many :locations, through: :festival_locations
  has_many :films, dependent: :destroy

  attr_accessible :ends_on, :location, :main_url, :name, :public, :revised_at,
                  :scheduled, :slug, :slug_group, :starts_on, :updates_url

  before_validation :update_slug

  validates :slug, presence: true, uniqueness: true
  validates :location, :name, :slug_group, :starts_on, :ends_on, presence: true
  validate :date_range_ordering

private
  def update_slug
    self.slug = "#{slug_group}_#{starts_on.strftime("%Y")}" if slug_group && starts_on
  end

  def date_range_ordering
    return true unless (ends_on < starts_on rescue false)

    errors.add(:ends_on, "cannot be before the start date")
    false
  end
end
