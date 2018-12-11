FactoryBot.define do
  factory :day do
    transient { festival nil }
    transient { screenings nil }
    initialize_with do
      my_screenings = screenings || begin
        my_festival = festival || \
          create(:festival, :with_films_and_screenings, day_count: 1)
        my_festival.screenings.on(my_festival.starts_on)
      end
      new(my_screenings.first.starts_at.to_date, my_screenings)
    end
  end
end
