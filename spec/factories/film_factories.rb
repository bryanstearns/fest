FactoryGirl.define do
  factory :film do
    sequence(:name) {|n| "Jaws #{n}" }
    duration 90
    countries "us"
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
