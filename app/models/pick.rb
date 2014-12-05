class Pick < ActiveRecord::Base
  belongs_to :festival
  belongs_to :film
  belongs_to :screening
  belongs_to :user

  RATING_HINTS = {
      1 => "1 star: It was bad",
      2 => "2 stars: It wasn't very good",
      3 => "3 stars: It was alright",
      4 => "4 stars: It was good",
      5 => "5 stars: It was *really* good",
  }

  PRIORITY_HINTS = {
      0 => "I don't want to see this; never schedule it for me",
      1 => "I'd see this, but only if there's room in my schedule",
      2 => "I'd see this",
      4 => "I want to see this",
      8 => "I *really* want to see this!"
  }

  before_validation :check_foreign_keys
  before_save :deselect_conflicting_screenings
  before_save :clear_auto_without_screening

  validates :user_id, :film_id, :festival_id, presence: true
  validates :priority, :rating, numericality: true, allow_nil: true
  validates :priority, inclusion: { in: PRIORITY_HINTS.keys }, allow_nil: true
  validates :rating, inclusion: { in: RATING_HINTS.keys }, allow_nil: true

  scope :selected, -> { where('picks.screening_id is not null') }
  scope :rated, -> { where('picks.rating is not null') }
  scope :prioritized_or_rated, -> { where('(picks.priority is not null or picks.rating is not null)') }
  scope :for_ffff_users, -> { joins(:user).where('users.ffff = ?', true) }

  delegate :countries, :name, :sort_name, to: :film, prefix: true

  def self.priority_to_index
    @@priority_to_index ||= {}.tap do |result|
      PRIORITY_HINTS.keys.each_with_index do |priority, index|
        result[priority] = index
      end
    end
  end

  def conflicting_screening_ids
    if screening_id?
      festival.conflicting_screenings(screening, user_id).map {|s| s.id }
    else
      []
    end
  end

  def conflicting_picks
    ids = conflicting_screening_ids - [id]
    ids.empty? ? [] : Pick.where(user_id: user_id, screening_id: ids)\
                          .includes(:screening, :film)
  end

  def changed_screening_ids(more=nil)
    @changed_screening_ids ||= []
    @changed_screening_ids += more if more
    @changed_screening_ids
  end

  def screenings_of_films_of_changed_screenings
    Screening.includes(film: :screenings)\
             .find(changed_screening_ids.compact).map do |screening|
      screening.film.screenings
    end.flatten
  end

protected
  def check_foreign_keys
    self.film ||= screening.film if screening
    self.festival_id ||= film.festival_id if film
  end

  def deselect_conflicting_screenings
    if screening_id_changed?
      changed_screening_ids(screening_id_change) # both old and new
      conflicts = conflicting_picks
      if conflicts.present?
        changed_screening_ids(conflicts.map {|p| p.screening_id })
        conflicts.update_all(screening_id: nil, auto: false)
      end
    end
    true
  end

  def clear_auto_without_screening
    self.auto = false unless screening_id.present?
    true
  end
end
