class Announcement < ActiveRecord::Base
  attr_accessible :contents, :published, :published_at, :subject

  default_scope order(:published_at).reverse_order

  validates :subject, :contents, presence: true

  before_save :set_published_at

  scope :published, where(published: true)

protected
  def set_published_at
    self.published_at ||= Time.current if published?
    true
  end
end
