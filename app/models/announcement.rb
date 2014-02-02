class Announcement < ActiveRecord::Base
  attr_accessible :contents, :published, :published_at, :subject

  validates :subject, :contents, presence: true

  before_save :set_published_at

  scope :published, where(published: true)

  scope :published_since, ->(time) { published.where('published_at > ?', time) }

protected
  def set_published_at
    self.published_at ||= Time.current if published?
    true
  end
end
