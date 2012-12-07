FactoryGirl.define do
  factory :film do
    sequence(:name) {|n| "Jaws #{n}" }
    duration 90
    countries "us"
    association :festival
  end
end
