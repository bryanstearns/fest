module FestivalsHelper
  def festival_dates(festival)
    date_range(festival.starts_on, festival.ends_on)
  end
end
