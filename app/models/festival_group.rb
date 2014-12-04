
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

  def latest_festival_start
    festivals.first.starts_on
  end

  def <=>(other)
    latest_festival_start <=> other.latest_festival_start
  end
  include Comparable
end
