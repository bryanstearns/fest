FactoryBot.define do
  factory :location do
    sequence(:name) {|n| "Location #{n}"}
    place "Portland, Oregon"
    parking_minutes 12
    trait :with_venues do
      transient { venue_count 3 }
      after(:create) do |location, ev|
        FactoryBot.create_list(:venue, ev.venue_count, location: location)
      end
    end
  end
end
