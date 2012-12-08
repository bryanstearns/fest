FactoryGirl.define do
  factory :screening do
    sequence(:name) {|n| "Jaws #{n}" }
    duration 90
    countries "us"
    association :film
    festival {|s| s.film.festival }
  end
end
