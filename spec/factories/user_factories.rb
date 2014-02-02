FactoryGirl.define do
  factory :user do
    sequence(:name) {|n| "Factory User #{n}" }
    sequence(:email) {|n| "user#{n}@example.com" }
    password "sw0rdf1sh!"
    password_confirmation "sw0rdf1sh!"
    welcomed_at Time.zone.parse("2000-01-01")

    factory :unconfirmed_user do
      sequence(:unconfirmed_email) {|n| "unconfirmed_user#{n}@example.com" }
    end

    factory :confirmed_user do
      confirmed_at Time.zone.parse("2000-01-01")

      factory :confirmed_admin_user do
        admin true
      end
    end

    trait :with_ratings do
      ignore { festival nil }
      after(:create) do |user, ev|
        festival = ev.festival || create(:festival, :with_films_and_screenings)
        create(:subscription, festival: festival, user: user)
        festival.films.order(:id).limit(5).each do |film|
          rating = (film.id % 5) + 1
          create(:pick, user: user, festival: festival, film: film,
                 rating: rating)
        end
      end
    end
  end
end
