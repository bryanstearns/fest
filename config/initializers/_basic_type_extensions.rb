
class Time
  def at(time)
    # Replace the time portion of this time with this new time, either as
    # a string we'll parse, or another time (and we'll ignore its date)
    h, m, s = case time
      when String
        time.split(":").map {|n| n.present? ? n.to_i : 0 }
      else
        [time.hour, time.min, time.sec]
    end
    s ||= 0
    self.change(hour: h, min: m, sec: s)
  end

  def round_down(interval=60)
    # Return ourself, rounded down to next even interval
    excess_seconds = (min % interval).minutes + sec
    return self if excess_seconds == 0 # already at that interval
    self - excess_seconds
  end

  def round_up(interval=60)
    # Return ourself, rounded up to next hour
    down = round_down(interval)
    return self if self == down # already at that interval
    down + interval.minutes
  end

  def to_minutes
    # minutes since the start of today
    hour.minutes + min
  end
end

class Date
  def at(time)
    self.in_time_zone.at(time)
  end
end

class Integer
  def to_minutes
    (self + 59) / 60
  end
end

class Float
  def to_minutes
    (self / 60.0).to_i
  end
end

class Numeric
  WORDS = %w[no one two three four five six seven eight nine ten]
  def in_words
    WORDS.fetch(self, self.to_s)
  end
  def counted(noun)
    noun = noun.pluralize if self != 1
    self.in_words + ' ' + noun
  end

  def to_duration
    # Format a duration (in seconds) meaningfully: "0.100ms", "3s", "4.05m"
    return sprintf("%0.3gd", self / 1.0.day) if self > 2.days
    return sprintf("%0.3gh", self / 1.0.hour) if self > 2.hours
    return sprintf("%0.3gm", self / 1.0.minute) if self > 2.minutes
    return sprintf("%0.3gms", self * 1000.0) if self < 0.1.seconds
    (self.truncate == self) ? "#{self}s" : sprintf("%0.3gs", self)
  end
end

module Enumerable
  def map_by(symbol=nil)
    if symbol
      inject({}) {|h, item| h[item.send(symbol)] = item; h }
    elsif block_given?
      inject({}) {|h, item| h[yield(item)] = item; h }
    else
      raise ArgumentError, "symbol or block required"
    end
  end
end
