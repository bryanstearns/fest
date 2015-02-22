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

  def countries(film)
    names = country_names(film.countries)
    names = 'Other' if names.blank?
    names
  end

  def festival_site_film_url(film, festival=nil)
    festival ||= film.festival
    return nil unless film.url_fragment.present? && festival.main_url.present?
    festival.main_url + film.url_fragment
  end

  def film_catalog_link(film, label=nil, festival=nil)
    url = festival_site_film_url(film, festival)
    label ||= film.name
    link_to_if(url, label, url, target: "_blank")
  end

  def film_details(film, festival=nil)
    parts = []
    parts << (flags(film.countries) + country_names(film.countries)) if film.countries?
    parts << hours_and_minutes(film.duration)
    parts << film_catalog_link(film, "page #{film.page_number}", festival) if film.page_number?
    content_tag(:span, safe_join(parts, ", "), class: "film_details")
  end
end
