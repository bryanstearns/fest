namespace :intervals do
  desc "Load a travel intervals from a CSV"
  task :load => :environment do
    require 'csv'
    dry_run = ENV["DRY_RUN"]
    verbose = (ENV["VERBOSE"] || 0).to_i
    place = ENV["PLACE"] || abort("Must specify PLACE!")
    ActiveRecord::Base.transaction do
      csv = ENV['CSV'] || abort("no CSV= specified")
      locations_by_name = Location.where(place: place).order(:name).inject({}) {|h, l| h[l.name] = l; h }
      index_to_location = nil
      CSV.foreach(csv) do |row|
        puts row.inspect if verbose > 2
        if index_to_location.nil? # we haven't extracted headers yet
          if row.compact.length > 3
            index_to_location = {}
            row.each_with_index do |name, i|
              location = locations_by_name[name]
              if location
                index_to_location[i-1] = location
              elsif !name.ends_with?(":")
                puts "Ignoring location column: #{name}" if verbose > 1
              end
            end
          elsif verbose > 2
            puts "Skipping pre-header row"
          end
        else
          from_location = locations_by_name[row[0]]
          if from_location
            row[1..-1].each_with_index do |value, i|
              to_location = index_to_location[i]
              if to_location.nil?
                puts "Ignoring destination column #{i}: #{value}" if verbose > 1
              elsif (to_location.id == from_location.id)
                puts "Skipping x = x" if verbose > 2
              else
                location_ids = [from_location.id, to_location.id].sort
                interval = TravelInterval.where(from_location_id: location_ids.first,
                                                to_location_id: location_ids.last)\
                                         .first_or_initialize
                time = value.to_i * 60.seconds
                if location_ids.first == from_location.id
                  puts "Updating #{from_location.name} #{from_location.id} -> #{to_location.name} #{to_location.id} to #{time.to_duration}" if verbose > 0
                  interval.seconds_from = time
                else
                  puts "Updating #{to_location.name} #{to_location.id} <- #{from_location.name} #{from_location.id} to #{time.to_duration}" if verbose > 0
                  interval.seconds_to = time
                end
                interval.save!
              end
            end
          else
            puts "Ignoring location row: #{row[0]}" if verbose > 1
          end
        end
      end
      if dry_run
        puts "... dry run, rolling back."
        raise ActiveRecord::Rollback
      end
    end
  end

  desc "Load travel intervals from Google"
  task :google => :environment do
    require 'csv'
    ENV["GOOGLE_MAP_DIRECTIONS_API_KEY"] || abort("Must specify GOOGLE_MAP_DIRECTIONS_API_KEY")

    place = ENV["PLACE"] || "Portland, Oregon"
    dry_run = ENV["DRY_RUN"]
    verbose = (ENV["VERBOSE"] || 0).to_i

    ActiveRecord::Base.transaction do
      TravelInterval.where("user_id is null").destroy_all

      locations = Location.where(place: place).order('name').to_a
      locations.each do |from_location|
        locations.each do |to_location|
          if from_location != to_location
            location_ids = [from_location.id, to_location.id].sort
            interval = TravelInterval.where(from_location_id: location_ids.first,
                                            to_location_id: location_ids.last)\
                                     .first_or_initialize
            time = google_travel_time(from_location, to_location, verbose).to_i * 60.seconds
            if location_ids.first == from_location.id
              puts "Updating #{from_location.name} #{from_location.id} -> #{to_location.name} #{to_location.id} to #{time.to_duration}" if verbose > 0
              interval.seconds_from = time
            else
              puts "Updating #{to_location.name} #{to_location.id} <- #{from_location.name} #{from_location.id} to #{time.to_duration}" if verbose > 0
              interval.seconds_to = time
            end
            interval.save!
          end
        end
      end

      if dry_run
        puts "... dry run, rolling back."
        raise ActiveRecord::Rollback
      end
    end
  end

  def google_travel_time(from_location, to_location, verbose)
    line_minutes = TravelInterval::DEFAULT_INTRA_INTERVAL / 60
    if from_location == to_location
      return line_minutes
    end

    driving = GoogleTravelTime.new(from_location.googleable_address,
                                   to_location.googleable_address, :driving)
    driving_time = driving.duration
    driving_total = driving_time + to_location.parking_minutes + line_minutes
    if verbose > 1
      puts "#{from_location.name} -> #{to_location.name}:"
      puts "  #{driving_total} = #{driving_time} driving + " +
           "#{to_location.parking_minutes} parking + " +
           "#{line_minutes} line from #{driving.url}"
    end

    walking = nil
    if driving_time < 10
      walking = GoogleTravelTime.new(from_location.googleable_address,
                                     to_location.googleable_address, :walking)
      walking_time = walking.duration
      walking_total = walking_time + line_minutes
      if verbose > 1
        puts "  #{walking_total} = #{walking_time} walking + #{line_minutes} line " +
             "from #{walking.url}"
      end
      if walking_total < 15
        puts "  using 15-minute minimum" if verbose > 1
        return 15
      end
      if walking_time < driving_time + to_location.parking_minutes
        puts "  using walking!" if verbose > 1
        return walking_total
      end
    end
    puts "  using driving!" if walking && verbose > 1
    driving_total
  end

  desc "Dump travel intervals to a CSV"
  task :dump => :environment do
    require 'csv'
    user = User.find_by_email(ENV['USER']) if ENV['USER']
    place = ENV["PLACE"]
    abort("Must specify PLACE!") unless (place || user)
    default_interval = (ENV["DEFAULT"] || TravelInterval::DEFAULT_INTER_INTERVAL).to_i
    csv_path = ENV['CSV']
    csv_path = "travel_times.csv" if csv_path == "1"
    csv = File.open(csv_path, 'w') if csv_path
    begin
      csv.puts "Festival Fanatic Travel Times#{ " -- #{place || user.name}" if (place || user)}"
      csv.puts ""
      csv.puts "This table shows the travel times in each direction between venues; some of the venues aren't used this year but I kept them for testing with last year's data; ignore them."
      csv.puts "Read down the left column to find the starting theater, then across to the destination theater's column."
      csv.puts "In filling out this table, I assumed that people would walk between downtown venues and drive between downtown and the outlying venues. (Cinema 21 is outlying.) The parking time is added already if necessary."
      csv.puts "If you'd like to suggest changes, please edit this spreadsheet and mail it back (as an email attachment) to festfan@festivalfanatic.com"
      csv.puts ""

      cache = TravelInterval.make_cache(user.try(:id), default_interval)
      locations = Location
      locations = locations.where(place: place) if place
      locations = locations.order('name').to_a
      labels = ['minutes from v to:'] + locations.map(&:name)
      widths = labels.map {|l| l.length }
      format = widths.map {|w| "%#{w + 2}s" }.join('  ')
      puts(format % labels)
      csv.puts(labels.to_csv) if csv
      locations.each do |from_location|
        values = [from_location.name] + locations.map do |to_location|
          (cache.between(from_location, to_location) / 60)
        end
        puts(format % values)
        csv.puts(values.to_csv) if csv
      end
    ensure
      csv.close if csv
    end
  end

  desc "Delete a user's travel intervals"
  task :delete => :environment do
    require 'debugger'
    user = User.find_by_email!(ENV['USER'])
    TravelInterval.where(user_id: user.id).map(&:destroy)
  end
end
