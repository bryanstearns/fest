module ScreeningsHelper
  def screening_times(screening, options={})
    result = time_range(screening)
    if options[:with_date]
      result = safe_join [
        l(screening.starts_at.to_date, format: :dmd),
        ', ',
        result
      ]
    end
    result
  end

  def other_screenings_caption(boundary_time, other_screenings)
    earlier, later = *other_screenings.partition {|s| s.starts_at < boundary_time }\
                                     .map(&:count)
    if earlier == 0
      if later == 0
        "No other screenings."
      else
        later.counted("later screening") + ":"
      end
    else
      if later == 0
        earlier.counted("earlier screening") + ':'
      else
        earlier.in_words + " earlier and " + later.counted("later screening") + ":"
      end
    end.capitalize
  end

  def format_film_description(description)
    safe_join(description.split("\n"), "<br>".html_safe)
  end
end
