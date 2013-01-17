class Pick < ActiveRecord::Base
  belongs_to :festival
  belongs_to :film
  belongs_to :screening
  belongs_to :user

  attr_accessible :priority, :rating, :screening, :screening_id
  attr_accessible :festival, :festival_id, :film, :film_id, :priority, :rating, :screening, :screening_id,
                  as: :pick_creator

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

  validates :user_id, :film_id, :festival_id, presence: true
  validates :priority, :rating, numericality: true, allow_nil: true
  validates :priority, inclusion: { in: PRIORITY_HINTS.keys }, allow_nil: true
  validates :rating, inclusion: { in: RATING_HINTS.keys }, allow_nil: true

  def self.priority_to_index
    @@priority_to_index ||= {}.tap do |result|
      PRIORITY_HINTS.keys.each_with_index do |priority, index|
        result[priority] = index
      end
    end
  end

protected
  def check_foreign_keys
    self.film ||= screening.film if screening
    self.festival_id ||= film.festival_id if film
  end
end
