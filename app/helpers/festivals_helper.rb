
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
end
