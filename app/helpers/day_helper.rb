module DayHelper
  def hour_steps(starts_at, ends_at)
    t = starts_at
    while t < ends_at
      yield t
      t += 1.hour
    end
  end

  def hour_label(t)
    if t.min == 0
      i = [0, 12].index(t.hour)
      return ["mid", "noon"][i] if i
    end
    l t, format: :hp
  end
end
