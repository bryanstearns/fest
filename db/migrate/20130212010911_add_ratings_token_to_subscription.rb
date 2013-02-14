class AddRatingsTokenToSubscription < ActiveRecord::Migration
  def change
    add_column :subscriptions, :ratings_token, :string, unique: true

    Subscription.reset_column_information
    Subscription.find_each do |subscription|
      subscription.save! # validation will assign keys
    end
  end
end
