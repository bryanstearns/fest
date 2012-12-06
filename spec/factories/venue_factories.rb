FactoryGirl.define do
  factory :venue do
    sequence(:name) {|n| "Venue #{n}"}
    sequence(:abbreviation) {|n| "V#{n}"}
    # we don't set a location; we're created from the Location factory.
  end
end
