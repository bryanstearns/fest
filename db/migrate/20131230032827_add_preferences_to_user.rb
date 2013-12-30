class AddPreferencesToUser < ActiveRecord::Migration
  def change
    add_column :users, :preferences, :hstore
    add_hstore_index :users, :preferences
  end
end
