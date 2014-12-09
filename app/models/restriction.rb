class Restriction
  ALMOST_A_DAY = 86399 # one second less than one day

  attr_accessor :starts_at, :ends_at

  def initialize(starts_at, ends_at=nil)
    @starts_at = starts_at.in_time_zone
    @ends_at = (ends_at || rounded_end_of_day(starts_at)).in_time_zone
  end

  def self.dump(restrictions)
    return nil unless restrictions.present?
    restrictions.map {|r| r.to_text }.join(', ')
  end

  def to_text
    result = "#{starts_at.month}/#{starts_at.day}"
    return result if (starts_at.seconds_since_midnight == 0 &&
        ends_at.seconds_since_midnight == ALMOST_A_DAY)
    starts_text = format_time(starts_at, 0)
    ends_text = format_time(ends_at, ALMOST_A_DAY)
    "#{result} #{starts_text}-#{ends_text}"
  end

  def format_time(t, default=nil)
    return "" if t.seconds_since_midnight == default
    hour = t.hour % 12
    t.strftime(t.min == 0 ? "#{hour}%P" : "#{hour}:%M%P")
  end

  def self.load(text, context_date)
    return [] unless text.present?
    context_date = context_date.to_date
    text.gsub(%r/\s{2,}/, ' ').split(',').map do |raw|
      parse_one_day(raw, context_date) unless raw.blank?
    end.compact.flatten
  end

  def self.parse_one_day(text, context_date)
    date_text, times_text = text.split(' ', 2)
    date_text.strip!
    raise(ArgumentError, "Was expecting '#{date_text}' to be a date like mm/dd.") \
      unless date_text =~ %r/^\d\d?\/\d\d?$/
    date = Time.zone.parse(date_text, context_date) || \
      raise(ArgumentError, "Can't figure out this date: '#{date_text}'.")
    diff = context_date - date.to_date
    if diff > 300
      date += 1.year
    elsif diff < -300
      date -= 1.year
    end
    parse_time_ranges(times_text, date)
  end

  def self.parse_time_ranges(times_text, date)
    times_text = "0:00-23:59:59" if times_text.blank?
    times_text.split('&').inject([]) do |results, range_text|
      starts_text, ends_text = range_text.strip.split('-')
      starts_at = parse_time(starts_text, date, '0:00')
      ends_at = parse_time(ends_text, date, '23:59:59')
      results << Restriction.new(starts_at, ends_at)
    end
  end

  def self.parse_time(time_text, date, default="0:00")
    text = time_text.blank? ? default : time_text.strip
    raise(ArgumentError, "Invalid time: '#{time_text}'") \
      unless text =~ %r/^\d\d?(:\d\d(:\d\d)?)?\s?(am|pm)?$/
    text += ":00" if text =~ %r/^\d+$/
    begin
      parsed = Time.zone.parse(text, date)
    rescue
      raise(ArgumentError, "'#{time_text}' doesn't seem to be a time.")
    end
    raise(ArgumentError, "'#{time_text}' doesn't seem to be a time.") \
      unless parsed
    parsed
  end

  def overlaps?(other)
    (starts_at < other.ends_at) && (ends_at > other.starts_at)
  end

  def ==(other)
    (starts_at == other.starts_at) and (ends_at == other.ends_at)
  end

  def inspect
    "<Restriction #{starts_at.inspect}-#{ends_at.inspect}>"
  end

private
  def rounded_end_of_day(time)
    # #end_of_day includes .999999 usec, which throws off our other
    # calculations.
    time.beginning_of_day + ALMOST_A_DAY
  end
end
