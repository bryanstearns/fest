namespace :intervals do
  desc "Load a travel intervals from a CSV"
  task :load => :environment do
    require 'csv'
    require 'debugger'
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

  desc "Dump travel intervals to a CSV"
  task :dump => :environment do
    user = User.find_by_email(ENV['USER']) if ENV['USER']
    place = ENV["PLACE"]
    abort("Must specify PLACE!") unless (place || user)
    csv_path = ENV['CSV']
    csv_path = "travel_times.csv" if csv_path == "1"
    csv = File.open(csv_path, 'w') if csv_path
    begin
      cache = TravelInterval.make_cache(user.try(:id))
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
