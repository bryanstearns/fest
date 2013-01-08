
class FestivalGroup
  extend ActiveModel::Naming
  attr_accessor :name, :slug

  def initialize
    @festivals = []
  end

  def <<(festival)
    @sorted = nil
    @festivals << festival
    self
  end

  def festivals
    @sorted ||= @festivals.sort_by {|f| f.starts_on }.reverse.tap do |result|
      @name = result.first.try(:name)
      @slug = result.first.try(:slug_group)
    end
  end

  def name
    festivals # make sure we've sorted
    @name
  end

  def slug
    festivals # make sure we've sorted
    @slug
  end

  # I'm not sure why, but extending ActiveModel::Naming above triggers its own
  # deprecation warning: "DEPRECATION WARNING: partial_path is deprecated and
  # will be removed from Rails 4.0 (ActiveModel::Name#partial_path is
  # deprecated. Call #to_partial_path on model instances directly instead.)."
  # This works around that. TODO: Fix w/Rails4?
  raise "Fix FestivalGroup TODO; see #{__FILE__}:#{__LINE__}" \
    if Rails.version.starts_with?("4")
  def to_partial_path
    "festival_groups/festival_group"
  end

  def latest_festival_start
    festivals.first.starts_on
  end

  def <=>(other)
    latest_festival_start <=> other.latest_festival_start
  end
  include Comparable
end
