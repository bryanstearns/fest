require 'date'
require 'tzinfo'
require 'icalendar'
require 'icalendar/tzinfo'

class CalendarFormatter
  include Icalendar
  include Rails.application.routes.url_helpers

  attr_reader :screenings

  def initialize(screenings)
    @screenings = screenings
    @version = "1.0"
  end

  def filename
    "#{@version}.ics"
  end

  def to_ics
    calendar = Calendar.new
    calendar.prodid Rails.application.routes.default_url_options[:host]

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
