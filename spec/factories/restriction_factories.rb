FactoryGirl.define do
  factory :restriction do
    ignore { starts_at nil }
    ignore { ends_at nil }
    initialize_with do
      new(starts_at, ends_at)
    end
  end
end
