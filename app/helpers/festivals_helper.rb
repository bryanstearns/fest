
module FestivalsHelper
  def current_page_in_admin?
    request.path.start_with?('/admin/')
  end

  def in_groups(festivals)
    # Return a list of festival groups, ordered by each group's last festival;
    # Within each group, festivals are latest first.
    festivals.inject({}) do |h, festival|
      (h[festival.slug_group] ||= FestivalGroup.new) << festival
      h
    end.values.sort.reverse
  end

  def festival_editing_current?(festival, film)
    # Should we show the admin Edit button as the current tab in the festival
    # navbar?
    return false unless festival
    return true if [
      festival_films_path(festival),
      new_festival_film_path(festival),
    ].any? {|p| current_page?(p) }

    return false unless film
    [
      edit_film_path(film)
    ].any? {|p| current_page?(p) }
  end

  def days(festival, options)
    days = festival.screenings_by_date(options)\
       .map do |date, screenings|
      Day.new(date, screenings)
    end
    if festival.slug == 'piff_2014'
      days << Day.new(Date.parse("2014-02-09"), [])
      days = days.sort_by {|day| day.date }
    end
    days
  end
end
