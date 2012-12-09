module ScreeningsHelper
  def screening_times(screening)
    "#{l screening.starts_at, format: :dmdy_hm} - " +
        "#{l screening.ends_at, format: :hm}"
  end
end
