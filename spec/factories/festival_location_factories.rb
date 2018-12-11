FactoryBot.define do
  factory :festival_location do
    association :festival
    association :location
  end
end
