class Question < ActiveRecord::Base
  belongs_to :user

  include BlockedEmailAddressChecks

  attr_accessible :acknowledged, :done, :email, :name, :question, :user_id

  default_scope { order(:created_at, :id).reverse_order }
  scope :not_done, -> { where(done: false) }

  validates :email, :question, :name, presence: true
  validates :email, format: { with: Devise::email_regexp }
end
