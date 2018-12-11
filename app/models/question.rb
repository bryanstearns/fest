class Question < ApplicationRecord
  belongs_to :user

  include BlockedEmailAddressChecks

  default_scope { order(created_at: :desc, id: :desc) }
  scope :not_done, -> { where(done: false) }

  validates :email, :question, :name, presence: true
  validates :email, format: { with: Devise::email_regexp }
end
