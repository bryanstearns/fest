FactoryGirl.define do
  factory :subscription do
    association :user
    association :festival
    show_press true
  end
end
