class Question < ActiveRecord::Base
  belongs_to :user

  attr_accessible :acknowledged, :done, :email, :name, :question, :user_id

  default_scope order(:created_at).reverse_order

  validates :email, :question, :name, presence: true
  validates :email, format: { with: Devise::email_regexp }
end
