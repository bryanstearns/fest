FactoryGirl.define do
  factory :user do
    name "Factory User"
    sequence(:email) {|n| "user#{n}@example.com" }
    password "sw0rdf1sh!"
    password_confirmation "sw0rdf1sh!"

    factory :confirmed_user do
      confirmed_at Time.zone.parse("2000-01-01")
    end
  end
end
