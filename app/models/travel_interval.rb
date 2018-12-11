class TravelInterval < ApplicationRecord
  DEFAULT_INTRA_INTERVAL = 10.minutes
  DEFAULT_INTER_INTERVAL = 15.minutes
  MAX_INTERVAL = 2.hours

  belongs_to :user
  belongs_to :from_location, class_name: 'Location'
  belongs_to :to_location, class_name: 'Location'

  before_validation :sort_location_ids

  scope :for_user_id, ->(user_id) do
    (user_id ? where('user_id is null or user_id = ?', user_id) \
             : where(user_id: nil)).order(:user_id)
  end

  class Cache
    def initialize(user_id, default_inter_interval=TravelInterval::DEFAULT_INTER_INTERVAL)
      @user_id = user_id
      @default_inter_interval = default_inter_interval

      @cache = Hash.new {|hf, fk| hf[fk] = {} }

      TravelInterval.for_user_id(user_id).inject(@cache) do |h, interval|
        h[interval.from_location_id][interval.to_location_id] = interval.seconds_from
        h[interval.to_location_id][interval.from_location_id] = interval.seconds_to
        h
      end
    end

    def between(from_location, to_location)
      from_location = from_location.id if from_location.is_a? Location
      to_location = to_location.id if to_location.is_a? Location
      return TravelInterval::DEFAULT_INTRA_INTERVAL if from_location == to_location

      @cache[from_location][to_location] || @default_inter_interval
    end
  end

  def self.reset_cache
    @interval_cache = nil
  end

  def self.between(from_location, to_location, user_id)
    interval_cache(user_id).between(from_location, to_location)
  end

  def self.interval_cache(user_id)
    @interval_cache ||= {}
    @interval_cache[user_id] ||= make_cache(user_id)
  end

  def self.make_cache(user_id, default_inter_interval=TravelInterval::DEFAULT_INTER_INTERVAL)
    TravelInterval::Cache.new(user_id, default_inter_interval)
  end

protected
  def sort_location_ids
    self.from_location_id, self.to_location_id, self.seconds_from, self.seconds_to =
       self.to_location_id, self.from_location_id, self.seconds_to, self.seconds_from \
      if self.from_location_id > self.to_location_id
  end
end
