FactoryGirl.define do
  factory :screening do
    association :film
    association :venue
    starts_at 2.days.ago.change(hour: 15, minute: 0, second: 0)
    press false
  end
end
