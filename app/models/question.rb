class Question < ActiveRecord::Base
  attr_accessible :acknowledged, :done, :email, :question

  default_scope order(:created_at).reverse_order

  validates :email, :question, presence: true
  validates :email, format: { with: Devise::email_regexp }
end
