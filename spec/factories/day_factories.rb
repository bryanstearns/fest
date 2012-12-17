FactoryGirl.define do
  factory :day do
    ignore { festival nil }
    ignore { screenings nil }
    initialize_with do
      festival ||= create(:festival, :with_films_and_screenings, day_count: 1)
      screenings ||= festival.screenings.on(festival.starts_on)
      new(screenings.first.starts_at.to_date, screenings)
    end
  end
end
