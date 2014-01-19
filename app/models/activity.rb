class Activity < ActiveRecord::Base
  belongs_to :user
  belongs_to :subject, polymorphic: true
  belongs_to :target, polymorphic: true
  serialize :details, Hash

  cattr_accessor :disabled

  default_scope order(:created_at).reverse_order

  attr_accessible :details, :festival_id, :name, :subject, :target, :user_id
end
