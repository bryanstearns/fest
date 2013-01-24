FactoryGirl.define do
  factory :subscription do
    association :user
    association :festival
    show_press true

    trait :skip_autoscheduler do
      skip_autoscheduler true
    end
  end
end
