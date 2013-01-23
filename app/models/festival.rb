class Festival < ActiveRecord::Base
  has_many :festival_locations, dependent: :destroy
  has_many :locations, through: :festival_locations
  has_many :venues, through: :locations
  has_many :films, dependent: :destroy
  has_many :screenings
  has_many :subscriptions, dependent: :destroy
  has_many :picks

  attr_accessible :ends_on, :location, :location_ids, :main_url, :name, :public,
                  :revised_at, :scheduled, :slug, :slug_group, :starts_on,
                  :updates_url

  before_validation :update_slug
  before_validation :default_revised_at, on: :create

  validates :slug, presence: true, uniqueness: true
  validates :ends_on, :location, :name, :revised_at, :slug_group, :starts_on,
            presence: true
  validate :date_range_ordering

  scope :public, where(public: true)

  def to_param
    slug
  end

  def screenings_by_date
    # NB: Since group_by returns an ordered hash, and we're feeding it screenings
    # in start-time order (the default for screenings), the keys of the
    # resulting hash will be in order.
    screenings.group_by {|s| s.starts_at.to_date }
  end

  def picks_for(user)
    picks.where(user_id: user.id)
  end

  def conflicting_screenings(screening)
    screenings.all.select {|s| screening.conflicts_with?(s) }
  end

private
  def update_slug
    self.slug = "#{slug_group}_#{starts_on.strftime("%Y")}" if slug_group && starts_on
  end

  def default_revised_at
    self.revised_at ||= Time.current
  end

  def date_range_ordering
    return true unless (ends_on < starts_on rescue false)

    errors.add(:ends_on, "cannot be before the start date")
    false
  end
end
