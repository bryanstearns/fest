
class TooManyVenueConflicts < ArgumentError; end

class Day
  # Presentation geometry for one day's screenings

  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_reader :date, :screenings
  attr_accessor :page_break_before

  # Geometry
  HOUR_HEIGHT = 50.0 # height of one hour in pixels
  MINUTE_HEIGHT = HOUR_HEIGHT / 60.0
  PADDING_HEIGHT = 9.0 # Padding we add around the screening
  PAGE_HEIGHT = 1000 # height of a page in pixels, for pagination
  DAY_HEADER_HEIGHT = 100 # slop we add to the grid height when paginating

  def initialize(date, screenings)
    @date = date
    @screenings = screenings
    @page_break_before = false
  end

  def starts_at
    @starts_at ||= screenings.map {|s| s.starts_at }.min.round_down
  end

  def ends_at
    @ends_at ||= screenings.map(&:ends_at).max.round_up
  end

  def grid_height
    (ends_at - starts_at).to_minutes * MINUTE_HEIGHT
  end

  def column_names
    viewings.keys.map {|column_key| column_key.venue_name }
  end

  def column_viewings
    viewings.values
  end

  def column_width
    100 / viewings.length
  end

  # Make dom_id happy
  def persisted?; true end # pretend we're always saved
  def to_param
    I18n.l(date, format: :ymd)
  end
  alias_method :id, :to_param

  def self.paginate(days, page_height = PAGE_HEIGHT)
    page_height = 0
    days.each do |day|
      page_height += day.grid_height + DAY_HEADER_HEIGHT
      if page_height > page_height
        day.page_break_before = true
        page_height = day.grid_height
      end
    end
    days
  end

private
  def viewings
    @viewings ||= ActiveSupport::OrderedHash.new() do |h,k|
      h[k] = []
    end.tap do |viewings|
      positioner = ViewingPositioner.new(starts_at)
      screenings.each do |screening|
        column_key, time_before = positioner.position_for(screening)
        viewings[column_key] <<
            Viewing.new(screening, time_before * MINUTE_HEIGHT,
                        (screening.duration.to_minutes * MINUTE_HEIGHT) -
                          PADDING_HEIGHT)
      end
    end
  end
end

class Viewing
  attr_reader :height, :screening, :space_before
  def initialize(screening, space_before, height)
    @screening = screening
    @space_before = space_before
    @height = height
  end

  delegate :name, to: :screening

  def times
    "timegoeshere"
  end
end

ColumnKey = Struct.new(:venue, :index) do
  def venue_name
    venue.name
  end
end

class ViewingPositioner
  MAX_ROOMS = 10
  def initialize(day_start)
    @day_start = day_start.to_minutes
    @next_time = {}
  end

  def position_for(screening)
    room_index = -1
    start = screening.starts_at.to_minutes
    begin
      room_index += 1
      raise(TooMenuVenueConflicts) if room_index > MAX_ROOMS
      column_key = ColumnKey.new(screening.venue, room_index)
      time_before = start - @next_time.fetch(column_key, @day_start)
    end while @next_time.has_key?(column_key) and (time_before < 0)
    @next_time[column_key] = start + screening.duration.to_minutes
    [column_key, time_before]
  end
end
