
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
end

class Date
  def at(time)
    self.to_time_in_current_zone.at(time)
  end
end
