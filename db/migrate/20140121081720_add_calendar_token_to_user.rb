class AddCalendarTokenToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :calendar_token, :string
  end
end
