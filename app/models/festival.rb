class Festival < ActiveRecord::Base
  has_many :festival_locations, dependent: :destroy
  has_many :locations, through: :festival_locations
  has_many :venues, through: :locations
  has_many :films, dependent: :destroy
  has_many :screenings
  has_many :subscriptions, dependent: :destroy
  has_many :users, through: :subscriptions
  has_many :picks
  has_many :activity

  before_validation :update_slug
  before_validation :default_revised_at, on: :create

  validates :slug, presence: true, uniqueness: true
  validates :ends_on, :name, :place, :revised_at, :slug_group, :starts_on,
            presence: true
  validate :date_range_ordering

  scope :published, -> { where(published: true) }

  RANDOM_UNASSIGNMENT_PERCENTAGE = 0.02
  RANDOM_REJECT_PERCENTAGE = 0.03

  def self.current
    published.where('starts_on <= ? and ends_on >= ?',
                    Date.today, 5.days.ago.to_date).
        order('starts_on').first
  end

  def self.upcoming
    where('starts_on >= ?', Date.tomorrow).order('starts_on').first
  end

  def self.have_testable_festival?
    upcoming || current
  end

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

  def screenings_for(user)
    screenings.joins(:picks).where('picks.user_id' => user.id)
  end

  def screenings_visible_to(user)
    subscription = user.subscription_for(id)
    screenings.all.select {|s| user.can_see?(s, subscription) }
  end

  def random_priorities(user)
    return if Rails.env.production?
    existing_picks = picks_for(user).each_with_object({}) {|p, h| h[p.film_id] = p }
    priorities = Pick::PRIORITY_HINTS.keys[1..-1] # skip "don't want to see"
    films.order(:sort_name).each do |film|
      pick = existing_picks[film.id]
      pick ||= picks.build.tap do |pick|
        pick.film = film
        pick.user = user
      end
      r = rand
      pick.priority = if r <= RANDOM_UNASSIGNMENT_PERCENTAGE
        nil # leave it unprioritized
      elsif r <= RANDOM_REJECT_PERCENTAGE
        0 # don't want to see at all
      else
        priorities.sample
      end
      pick.save!
    end
  end

  def reset_rankings(user)
    picks_to_reset = picks_for(user).prioritized_or_rated
    picks_to_reset.update_all(priority: nil, rating: nil)
  end

  def reset_screenings(user, mode=nil)
    return if mode == 'none'

    picks_to_reset = picks_for(user).selected
    picks_to_reset = picks_to_reset.joins(:screening)\
                                   .where('screenings.starts_at > ?',
                                          Time.current) if %w[future auto].include?(mode)
    picks_to_reset = picks_to_reset.where(auto: true) if mode == 'auto'
    picks_to_reset.update_all(screening_id: nil, auto: false)
  end

  def conflicting_screenings(screening, user_id)
    screenings.all.select {|s| screening.conflicts_with?(s, user_id) }
  end

  def is_latest_in_group?
    self == Festival.published.order(:starts_on).where(slug_group: slug_group).last
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
