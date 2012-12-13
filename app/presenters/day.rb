class Day
  # Presentation geometry for one day's screenings

  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :date, :screenings

  def initialize(date, screenings)
    @date = date
    @screenings = screenings
  end

  def starts_at
    @starts_at ||= screenings.map{|s| s.starts_at }.min.round_down
  end

  def ends_at
    @ends_at ||= screenings.map{|s| s.ends_at }.max.round_up
  end

  # Make dom_id happy
  def persisted?; true end # pretend we're always saved
  def to_param
    I18n.l(date, format: :ymd)
  end
  alias_method :id, :to_param
end
