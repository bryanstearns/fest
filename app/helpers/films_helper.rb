module FilmsHelper
  def hours_and_minutes(duration)
    duration = duration.to_minutes
    hours = duration / 60
    minutes = duration % 60
    [].tap do |result|
      result << pluralize(hours, "hour") if hours > 0
      result << pluralize(minutes, "minute") if minutes > 0
    end.join(" ")
  end
end
