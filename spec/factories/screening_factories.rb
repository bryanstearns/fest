FactoryBot.define do
  factory :screening do
    association :film
    association :venue
    starts_at 2.days.ago.at("15:00")
    press false
  end
end
