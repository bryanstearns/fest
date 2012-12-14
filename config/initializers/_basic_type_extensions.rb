
class Time
  def at(time)
    # Replace the time portion of this time with this new time, either as
    # a string we'll parse, or another time (and we'll ignore its date)
    h, m, s = case time
      when String
        time.split(":")
      else
        [time.hour, time.min, time.sec]
    end
    self.change(hour: h, min: m || 0, sec: s || 0)
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
    (hour * 60) + min
  end
end

class Date
  def at(time)
    self.to_time_in_current_zone.at(time)
  end
end

class Fixnum
  def to_minutes
    (self + 59) / 60
  end
end

class Float
  def to_minutes
    (self / 60.0).to_i
  end
end
