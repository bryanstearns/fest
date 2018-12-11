FactoryBot.define do
  factory :pick do
    association :user
    association :film
    association :festival
    screening { nil }
    priority { nil }
    rating { nil }
  end
end
