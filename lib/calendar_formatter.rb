require 'date'
require 'tzinfo'
require 'icalendar'
require 'icalendar/tzinfo'

class CalendarFormatter
  include Icalendar
  include Rails.application.routes.url_helpers

  attr_reader :screenings

  def initialize(user_name, screenings)
    @user_name = user_name
    @screenings = screenings
    @version = "1.0"
  end

  def filename
    "#{Time.now.iso8601}-#{SOURCE_REVISION_NUMBER}.ics"
  end

  def any_future_screenings?(now=nil)
    if !defined?(@any_future_screenings) || now
      now ||= Time.current
      @any_future_screenings = @screenings.any? {|s| s.ends_at > now }
    end
    @any_future_screenings
  end

  def refresh_interval
    any_future_screenings? ? "PT4H" : "P2D"
  end

  def to_ics
    calendar = Calendar.new
    calendar.prodid Rails.application.routes.default_url_options[:host]

    # Someday there'll be REFRESH-INTERVAL;VALUE=DURATION:PT12H, but for now:
    # http://tools.ietf.org/html/draft-daboo-icalendar-extensions-06
    # http://stackoverflow.com/questions/17152251/specifying-name-description-and-refresh-interval-in-ical-ics-format
    calendar.x_published_ttl = refresh_interval

    # Also someday: calendar.name = "#{@user_name}'s Screenings on Festival Fanatic"
    calendar.x_wr_calname = "#{@user_name}'s Screenings on Festival Fanatic"

    tzid = "America/Los_Angeles"
    tz = TZInfo::Timezone.get(tzid)
    timezone = tz.ical_timezone(screenings.first.starts_at)
    calendar.add(timezone)

    screenings.each do |screening|
      screening_url = festival_url(screening.festival_id,
                                   anchor: "s#{screening.id}")
      calendar.event do
        summary screening.name
        location screening.venue_name

        dtstart screening.starts_at.to_datetime.tap {|d| d.ical_params = { 'TZID' => tzid } }
        dtend screening.ends_at.to_datetime.tap {|d| d.ical_params = { 'TZID' => tzid } }

        created screening.created_at.to_datetime.tap {|d| d.ical_params = { 'TZID' => tzid } }
        last_modified screening.updated_at.to_datetime.tap {|d| d.ical_params = { 'TZID' => tzid } }

        uid screening_url
        url screening_url
      end
    end

    calendar.to_ical
  end
end
