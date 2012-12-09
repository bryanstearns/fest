FactoryGirl.define do
  factory :festival do
    location "Locationville, OR"
    sequence(:slug_group) {|n| "fest#{n}" }
    name {|f| "Festival #{f.slug_group}" }
    starts_on 2.days.ago
    ends_on {|f| f.starts_on.to_date + 2.days }

    trait :upcoming do
      sequence(:slug_group) {|n| "soon#{n}" }
      starts_on 40.days.from_now
    end

    trait :past do
      sequence(:slug_group) {|n| "past#{n}" }
      starts_on 40.days.ago
    end

    factory :festival_with_films do
      ignore { film_count 3 }
      after(:create) do |festival, ev|
        FactoryGirl.create_list(:film, ev.film_count, festival: festival)
      end
    end

    trait :with_venues do
      ignore do
        location_count 1
        venue_count 1
      end
      after(:create) do |festival, ev|
        FactoryGirl.create_list(:festival_location,
                                ev.location_count,
                                festival: festival).each do |fest_loc|
          FactoryGirl.create_list(:venue,
                                  ev.venue_count,
                                  location: fest_loc.location)
        end
      end
    end
  end
end
