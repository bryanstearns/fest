module FilmsHelper
  def hours_and_minutes(duration)
    duration = duration.to_minutes
    hours = duration / 60
    minutes = duration % 60
    [].tap do |result|
      result << pluralize(hours, 'hour') if hours > 0
      result << pluralize(minutes, 'minute') if minutes > 0
    end.join(' ')
  end

  def priority_dots(film)
    content_tag(:div, '', id: dom_id(film) + '_dots', class: 'dots')
  end

  def rating_stars(film)
    content_tag(:div, '', id: dom_id(film) + '_stars', class: 'stars')
  end

  def pick_symbols(film)
    content_tag(:div, '', id: dom_id(film) + '_pick', class: 'pick_symbols')
  end
end
