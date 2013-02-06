class Subscription < ActiveRecord::Base
  belongs_to :festival
  belongs_to :user
  serialize :excluded_location_ids

  attr_accessor :debug, :included_location_ids,
                :skip_autoscheduler, :unselect, :up_to_screening_id

  attr_accessible :debug, :included_location_ids, :restriction_text,
                  :show_press, :skip_autoscheduler, :unselect,
                  :up_to_screening_id
  attr_accessible :debug, :festival_id, :included_location_ids,
                  :restriction_text, :show_press, :skip_autoscheduler,
                  :unselect, :up_to_screening_id, as: :subscription_creator

  validate :check_restriction_text
  validate :check_location_exclusions

  before_validation :assign_sharing_key

  def can_see?(screening)
    return false if screening.press && !show_press?
    return false if restrictions && restrictions.any? {|r| r.overlaps?(screening) }
    return false if excluded_location_ids && excluded_location_ids.include?(screening.location_id)
    true
  end

  def restriction_text=(s)
    @restrictions_error = @restrictions = nil
    write_attribute(:restriction_text, s)
  end

  def restrictions
    @restrictions ||= begin
      @restrictions_error = nil
      Restriction.load(restriction_text, festival.starts_on).tap do |result|
        new_text = Restriction.dump(result)
        write_attribute(:restriction_text, new_text) \
          if new_text != restriction_text
      end
    rescue ArgumentError => e
      @restrictions_error = e.message
      []
    end
  end

  def check_restriction_text
    if restrictions && @restrictions_error
      errors.add('restriction_text', @restrictions_error)
    end
  end

  def key
    read_attribute(:key) || (Subscription.generate_key.tap do |result|
      write_attribute(:key, result)
    end)
  end
  alias_method :assign_sharing_key, :key

  def included_location_ids
    festival_location_ids - (excluded_location_ids || [])
  end

  def included_location_ids=(location_ids)
    excluded_list = festival_location_ids - location_ids.map {|id| id.to_i}
    self.excluded_location_ids = excluded_list.present? ? excluded_list : nil
  end

  def festival_location_ids
    festival.locations.map {|location| location.id }
  end

  def self.generate_key
    SecureRandom.hex(4)
  end

  def unselect
    @unselect || 'future'
  end

protected
  def check_location_exclusions
    return unless excluded_location_ids.present?
    errors.add(:excluded_location_ids, "You can't exclude all locations") \
      if (festival_location_ids - excluded_location_ids).empty?
  end
end
