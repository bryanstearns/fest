module ScreeningsHelper
  def screening_times(screening, options={})
    result = time_range(screening)
    if options[:with_date]
      result = safe_join [
        l(screening.starts_at.to_date, format: :mdy),
        ' ',
        result
      ]
    end
    result
  end
end
