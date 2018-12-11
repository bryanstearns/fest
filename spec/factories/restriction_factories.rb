FactoryBot.define do
  factory :restriction do
    transient { starts_at nil }
    transient { ends_at nil }
    initialize_with do
      new(starts_at, ends_at)
    end
  end
end
