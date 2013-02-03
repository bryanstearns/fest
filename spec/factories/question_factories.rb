FactoryGirl.define do
  factory :question do
    sequence(:email) {|n| "feedback_user#{n}@example.com" }
    question "What is your favorite color?"
  end
end
