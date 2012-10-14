class Festival < ActiveRecord::Base
  attr_accessible :ends_on, :location, :main_url, :name, :public, :revised_at,
                  :scheduled, :slug, :slug_group, :starts_on, :updates_url

  before_validation :update_slug

  validates :name, :slug, presence: true, uniqueness: true
  validates :location, :slug_group, presence: true

private
  def update_slug
    self.slug = "#{slug_group}_#{starts_on.strftime("%Y")}" if slug_group && starts_on
  end
end
