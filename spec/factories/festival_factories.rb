FactoryGirl.define do
  factory :festival do
    sequence(:name) {|n| "Festival #{n}" }
    location "Locationville, OR"
    sequence(:slug_group) {|n| "fest#{n}" }
    starts_on 2.days.ago
    ends_on {|f| f.starts_on + 2.days }

    trait :upcoming do
      sequence(:name) {|n| "SoonFestival #{n}" }
      sequence(:slug_group) {|n| "soon#{n}" }
      starts_on 40.days.from_now
    end

    trait :past do
      sequence(:name) {|n| "PastFestival #{n}" }
      sequence(:slug_group) {|n| "past#{n}" }
      starts_on 40.days.ago
    end
  end
end
