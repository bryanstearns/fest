class AddWelcomedAtToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :welcomed_at, :datetime

    User.reset_column_information
    User.find_each do |user|
      user.welcomed_at = Time.current
      user.save!
    end
  end
end
