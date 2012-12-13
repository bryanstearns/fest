
module FestivalsHelper
  def festival_dates(festival)
    date_range(festival.starts_on, festival.ends_on)
  end

  def in_groups(festivals)
    # Return a list of festival groups in order, with festivals in reverse
    # chronological order within each group
    festivals.inject({}) do |h, festival|
      (h[festival.slug_group] ||= FestivalGroup.new) << festival
      h
    end.values.sort_by(&:name)
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

  def days(festival)
    festival.screenings_by_date.map do |date, screenings|
      Day.new(date, screenings)
    end
  end
end
