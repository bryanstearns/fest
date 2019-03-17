
class FakeFestivalGenerator
  attr_reader :festival, :film_count, :press, :logger
  attr_accessor :day_count, :films, :venues

  HITCHCOCK_FILMS = {
      "Family Plot" => 120,
      "Frenzy" => 116,
      "Topaz" => 143,
      "Marnie" => 130,
      "The Birds" => 119,
      "Psycho" => 109,
      "North by Northwest" => 136,
      "Vertigo" => 128,
      "The Wrong Man" => 105,
      "Blackmail" => 84
  } unless defined?(HITCHCOCK_FILMS)

  def initialize(festival, film_count, press, logger=nil)
    @festival = festival
    @film_count = film_count
    @press = press
    @logger = case logger
    when :stdout
      ->(msg) { puts msg }
    when nil
      nil
    else
      ->(msg) { logger.fatal msg }
    end

    # We'll scale things (like venues & films) by the length of the festival
    @day_count = (festival.ends_on.to_date - festival.starts_on.to_date).to_i + 1
    log { "#{day_count} days, #{festival.inspect}" }
  end

  def run
    make_locations_and_venues
    make_films
    make_screenings
  end

  def make_locations_and_venues
    locations = FactoryBot.create_list(:location, (day_count / 3) + 1,
                                       :with_venues,
                                       place: festival.place)
    locations.each do |location|
      FactoryBot.create(:festival_location, festival: festival,
                        location: location)
    end
    @venues = festival.venues
    add_cycling_to(@venues)
  end

  def make_films
    count = film_count || (day_count * 4)
    @films = count.times.zip(HITCHCOCK_FILMS.keys.cycle).map do |i, name|
      suffix = " #{(i / HITCHCOCK_FILMS.count) + 1}" if i >= HITCHCOCK_FILMS.count
      log { "Film #{i}: Creating #{name}#{suffix}" }
      FactoryBot.create(:film, festival: festival, name: "#{name}#{suffix}",
                        duration: HITCHCOCK_FILMS[name].minutes)
    end
    add_cycling_to(@films)
  end

  def make_screenings
    first_date = festival.starts_on
    first_date -= 1 if press
    (first_date .. festival.ends_on).each_with_index do |date, day_index|
      log { "Starting #{date}" }
      t = date.at("18:00")
      limit = date.at("23:00")
      day_venues = venues.take_more((press && day_index == 0) ? 1 : 3)
      day_venues.each_with_index do |venue, i|
        tv = t + (5 * rand(3)).minutes
        log {"  #{i}: Venue #{venue.name}, starting at #{tv}" }
        loop do
          film = films.take_one
          starts_at = tv
          tv += film.duration + 10.minutes
          break if tv > limit
          log { "    Added #{film.name} at #{I18n.l tv, format: :mdy_hms}" }
          FactoryBot.create(:screening, film: film, venue: venue,
                            starts_at: starts_at, festival: festival,
                            press: press && day_index == 0)
        end
      end
    end
  end

  def add_cycling_to(things)
    class << things
      def take_more(take_count)
        @cycling_index ||= 0
        result = []
        while take_count > 0
          available = count - @cycling_index
          batch_count = take_count > available ? available : take_count
          result += to_ary.slice(@cycling_index, batch_count)
          @cycling_index = (@cycling_index + batch_count) % count
          take_count -= batch_count
        end
        result
      end
      def take_one
        take_more(1).first
      end
    end
  end

  def log
    logger && logger.call(yield)
  end
end

FactoryBot.define do
  factory :festival do
    transient { day_count { 1 } }
    place { "Placeville, Oregon" }
    sequence(:slug_group) {|n| "fest#{n}" }
    name {|f| "Festival #{f.slug_group}" }
    banner_name {|f| "Festival #{f.slug_group}" }
    starts_on { Date.yesterday }
    ends_on { starts_on.to_date + (day_count - 1) }
    main_url { "https://example.com/" }
    published { true }
    scheduled { true }

    trait :upcoming do
      sequence(:slug_group) {|n| "soon#{n}" }
      starts_on { 40.days.from_now.to_date }
      scheduled { false }
    end

    trait :past do
      sequence(:slug_group) {|n| "past#{n}" }
      starts_on { 367.days.ago.to_date }
    end

    trait :with_films_and_screenings do
      transient { film_count { nil } }
      transient { press { false } }
      after(:create) do |festival, ev|
        FakeFestivalGenerator.new(festival, ev.film_count, ev.press).run
      end
    end

    trait :with_screening_conflicts do
      after(:create) do |festival, ev|
        # Create screenings of two films that conflict
        screenings = 2.times.map do
          create(:screening, festival: festival,
                 film: create(:film, festival: festival),
                 starts_at: festival.starts_on.at("18:00"))
        end
        # Create a later screening of one of those films
        screenings << create(:screening, film: screenings.first.film,
                             starts_at: festival.starts_on.at("22:00"))
        # Create a screening of a third film that conflicts with the later one
        screenings << create(:screening, starts_at: festival.starts_on.at("22:00"))
      end
    end

    trait :with_films do
      transient { film_count { 3 } }
      after(:create) do |festival, ev|
        create_list(:film, ev.film_count, festival: festival)
      end
    end

    trait :with_venues do
      transient do
        location_count { 1 }
        venue_count { 1 }
      end
      after(:create) do |festival, ev|
        create_list(:festival_location, ev.location_count,
                    festival: festival).each do |fest_loc|
          create_list(:venue, ev.venue_count,
                      location: fest_loc.location)
        end
      end
    end
  end
end
