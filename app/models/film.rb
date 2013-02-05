class Film < ActiveRecord::Base
  belongs_to :festival, touch: true
  has_many :screenings, dependent: :destroy
  has_many :picks, dependent: :destroy

  attr_accessible :countries, :description, :duration, :name, :page, :url_fragment

  validates :duration, :festival_id, :name, presence: true
  validates :name, :uniqueness => { scope: :festival_id }

  before_save :initialize_sort_name
  after_save :touch_screenings

  scope :by_name, -> { order(:sort_name) }

  def page_number
    page.to_i if page.present?
  end

  def screenings_with_press(options)
    if options[:press]
      screenings # return them all, either way
    else
      # Load them all, then filter.
      screenings.to_a.select {|s| !s.press }
    end
  end

protected
  def initialize_sort_name
    self.sort_name ||= name
  end

  def touch_screenings
    # TODO: consider trying this in a single operation
    screenings.each {|s| s.touch }
  end
end
