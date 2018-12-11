FactoryBot.define do
  factory :announcement do
    subject { "Subject to Change" }
    contents { "This is the content of my message." }

    trait :published do
      published { true }
      published_at { 10.days.ago }
    end
  end
end
