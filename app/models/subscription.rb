class Subscription < ActiveRecord::Base
  belongs_to :festival
  belongs_to :user

  attr_accessible :show_press
  attr_accessible :festival_id, :show_press, as: :subscription_creator
end
