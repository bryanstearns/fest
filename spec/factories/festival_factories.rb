
class FakeFestivalGenerator
  attr_reader :festival, :film_count, :press, :verbose
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

  def initialize(festival, film_count, press)
    @festival = festival
    @film_count = film_count
    @press = press
    @verbose = false

    # We'll scale things (like venues & films) by the length of the festival
    @day_count = (festival.ends_on.to_date - festival.starts_on.to_date).to_i + 1

    puts "#{day_count} days, #{festival.inspect}" if verbose
  end

  def run
    make_locations_and_venues
    make_films
    make_screenings
  end

  def make_locations_and_venues
    locations = FactoryGirl.create_list(:location, (day_count / 3) + 1,
                                        :with_venues)
    locations.each do |location|
      FactoryGirl.create(:festival_location, festival: festival,
                         location: location)
    end
    @venues = festival.venues
  end

  def make_films
    count = film_count || (day_count * 10)
    @films = count.times.zip(HITCHCOCK_FILMS.keys.cycle).map do |i, name|
      suffix = " #{(i / HITCHCOCK_FILMS.count) + 1}" if i > HITCHCOCK_FILMS.count
      puts "Film #{i}: Creating #{name}#{suffix}" if verbose
      FactoryGirl.create(:film, festival: festival, name: "#{name}#{suffix}",
                         duration: HITCHCOCK_FILMS[name].minutes)
    end
  end

  def make_screenings
    first_date = festival.starts_on
    first_date -= 1 if press
    (first_date .. festival.ends_on).each_with_index do |date, day_index|
      puts "Starting #{date}" if verbose
      t = date.at("18:00")
      limit = date.at("23:00")
      day_venues = venues.sample((press && day_index == 0) ? 1 : 3)
      day_venues.each_with_index do |venue, i|
        tv = t + (5 * rand(3)).minutes
        puts "  #{i}: Venue #{venue.name}, starting at #{tv}" if verbose
        loop do
          film = films.sample
          starts_at = tv
          tv += film.duration + 10.minutes
          break if tv > limit
          puts "    Added #{film.name} at #{I18n.l tv, format: :mdy_hms}" \
                if verbose
          FactoryGirl.create(:screening, film: film, venue: venue,
                             starts_at: starts_at, festival: festival,
                             press: press && day_index == 0)
        end
      end
    end
  end
end

FactoryGirl.define do
  factory :festival do
    ignore { day_count 1 }
    location "Locationville, OR"
    sequence(:slug_group) {|n| "fest#{n}" }
    name {|f| "Festival #{f.slug_group}" }
    starts_on Date.yesterday
    ends_on { starts_on.to_date + (day_count - 1) }
    public true
    scheduled true

    trait :upcoming do
      sequence(:slug_group) {|n| "soon#{n}" }
      starts_on 40.days.from_now.to_date
      scheduled false
    end

    trait :past do
      sequence(:slug_group) {|n| "past#{n}" }
      starts_on 367.days.ago.to_date
    end

    trait :with_films_and_screenings do
      ignore { film_count nil }
      ignore { press false }
      after(:create) do |festival, ev|
        FakeFestivalGenerator.new(festival, ev.film_count, ev.press).run
      end
    end

    trait :with_films do
      ignore { film_count 3 }
      after(:create) do |festival, ev|
        create_list(:film, ev.film_count, festival: festival)
      end
    end

    trait :with_venues do
      ignore do
        location_count 1
        venue_count 1
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
