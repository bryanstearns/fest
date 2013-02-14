FactoryGirl.define do
  factory :subscription do
    association :user
    association :festival
    show_press false
    key Subscription.generate_key
    ratings_token Subscription.generate_key

    trait :skip_autoscheduler do
      skip_autoscheduler true
    end
  end
end
