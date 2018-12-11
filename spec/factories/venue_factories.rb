FactoryBot.define do
  factory :venue do
    sequence(:name) {|n| "Venue #{n}"}
    sequence(:abbreviation) {|n| "V#{n}"}
    association :location
  end
end
