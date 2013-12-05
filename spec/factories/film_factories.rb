FactoryGirl.define do
  factory :film do
    sequence(:name) {|n| "Jaws #{n}" }
    duration_minutes 90
    sequence(:countries) {|n| Countries::CODES[(n ^ 5) % Countries::CODES.length]}
    association :festival

    trait :with_screenings do
      ignore { screening_count 3 }
      after(:create) do |film, ev|
        FactoryGirl.create_list(:screening, ev.screening_count,
                                film: film, festival: film.festival)
      end
    end
  end
end
