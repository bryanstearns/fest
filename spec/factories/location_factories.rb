FactoryGirl.define do
  factory :location do
    sequence(:name) {|n| "Location #{n}"}
    place "Placeville, Oregon"
    trait :with_venues do
      ignore { venue_count 3 }
      after(:create) do |location, ev|
        FactoryGirl.create_list(:venue, ev.venue_count, location: location)
      end
    end
  end
end
