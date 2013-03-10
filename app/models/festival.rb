class Festival < ActiveRecord::Base
  has_many :festival_locations, dependent: :destroy
  has_many :locations, through: :festival_locations
  has_many :venues, through: :locations
  has_many :films, dependent: :destroy
  has_many :screenings
  has_many :subscriptions, dependent: :destroy
  has_many :picks

  attr_accessible :ends_on, :location_ids, :main_url, :name, :place, :published,
                  :revised_at, :scheduled, :slug, :slug_group, :starts_on,
                  :updates_url

  before_validation :update_slug
  before_validation :default_revised_at, on: :create

  validates :slug, presence: true, uniqueness: true
  validates :ends_on, :name, :place, :revised_at, :slug_group, :starts_on,
            presence: true
  validate :date_range_ordering

  scope :published, where(published: true)

  def to_param
    slug
  end

  def screenings_by_date(options)
    # NB: Since group_by returns an ordered hash, and we're feeding it screenings
    # in start-time order (the default for screenings), the keys of the
    # resulting hash will be in order.
    screenings.with_press(options[:press])\
              .group_by {|s| s.starts_at.to_date }
  end

  def picks_for(user)
    picks.where(user_id: user.id)
  end

  def screenings_visible_to(user)
    subscription = user.subscription_for(id)
    screenings.all.select {|s| user.can_see?(s, subscription) }
  end

  def reset_rankings(user)
    picks_to_reset = picks_for(user).prioritized_or_rated
    picks_to_reset.update_all(priority: nil, rating: nil)
  end

  def reset_screenings(user, after=nil)
    after = Time.current if after == :now
    picks_to_reset = picks_for(user).selected
    picks_to_reset = picks_to_reset.joins(:screening)\
                                   .where('screenings.starts_at > ?',
                                               after) if after
    picks_to_reset.update_all(screening_id: nil)
  end

  def conflicting_screenings(screening, user_id)
    screenings.all.select {|s| screening.conflicts_with?(s, user_id) }
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
