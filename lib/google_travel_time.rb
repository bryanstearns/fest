
require 'uri'
require 'active_support'
require 'active_support/core_ext/object/to_query'
require 'active_support/core_ext/time/calculations'
require 'active_support/core_ext/numeric/time'
require 'httparty'
require 'json'

class GoogleTravelTime
  BASE_URL = "https://maps.googleapis.com/maps/api/directions/json"
  API_KEY = ENV["GOOGLE_MAP_DIRECTIONS_API_KEY"]

  SCALE_FACTOR = {
    driving: 1.25,
    walking: 1.1
  }

  attr_accessor :mode

  def self.wednesday_at_5pm
    date = Time.current
    date = date.tomorrow while !date.wednesday?
    date.beginning_of_day + 17.hours
  end
  DEPARTURE_TIME = self.wednesday_at_5pm

  def initialize(origin, destination, mode = :driving)
    @origin = origin
    @destination = destination
    @mode = mode
  end

  def duration
    seconds = (routes
      .map do |route|
        route["legs"].map {|leg| leg["duration"]["value"] }.inject(0, :+)
      end
      .sort
      .last) || raise("no routes found from #{@origin} to #{@destination} : #{url}")

    # scale a bit, then convert to whole minutes
    ((seconds * SCALE_FACTOR[@mode]) / 60.0).round
  end

  def routes
    response["routes"]
  end

  def response
    result = JSON.parse(HTTParty.get(url).body)
    if result["status"] == "OVER_QUERY_LIMIT"
      puts "OVER QUERY LIMIT; sleeping 5s"
      sleep(5)
      response
    else
      result
    end
  end

  def url
    "#{BASE_URL}?#{query.to_query}"
  end

  def query
    result = {
      origin: @origin,
      destination: @destination,
      departure_time: DEPARTURE_TIME.to_i,
      key: API_KEY
    }
    if @mode == :driving
      result[:mode] = "driving"
      result[:traffic_model] = "pessimistic"
      result[:alternatives] = true
    else
      result[:mode] = "walking"
    end
    result
  end
end

if __FILE__ == $0
  locations = {
    "hollywood" => "Hollywood Theatre, Portland OR",
    "whitsell" => "Portland Art Museum, Portland OR",
    "valley" => "Valley Cinema and Pub, Beaverton OR"
  }

  locations.keys.each do |origin|
    locations.keys.each do |destination|
      if origin != destination
        gdt = GoogleTravelTime.new(locations[origin], locations[destination])
        time = gdt.duration
        puts "#{origin} -> #{destination}: #{time} from #{gdt.url}"
      end
    end
  end
end
