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

      trait :with_subscription do
        transient { festival nil }
        after(:create) do |user, ev|
          festival = ev.festival || create(:festival, :with_films_and_screenings)
          create(:subscription, festival: festival, user: user)
        end
      end

      trait :with_ratings do
        with_subscription
        after(:create) do |user, ev|
          subscription = user.subscriptions.preload(festival: :films).last
          festival = subscription.festival
          festival.films.order(:id).limit(5).each do |film|
            pick = user.picks.where(festival: festival, film: film).first_or_create
            pick.rating = (film.id % 5) + 1
            pick.save!
          end
        end
      end

      trait :with_priorities do
        with_subscription
        after(:create) do |user, ev|
          subscription = user.subscriptions.preload(festival: :films).last
          festival = subscription.festival
          festival.films.order(:id).limit(5).each do |film|
            pick = user.picks.where(festival: festival, film: film).first_or_create
            pick.priority = Pick::PRIORITY_HINTS.keys[(film.id % 5) + 1]
            pick.save!
          end
        end
      end

      trait :autoscheduled do
        with_priorities
        after(:create) do |user, ev|
          subscription = user.subscriptions.first
          AutoScheduler.new(user: user,
                            festival: subscription.festival,
                            subscription: subscription,
                            verbose: true).run
        end
      end
    end
  end
end
