class AddPreferencesToUser < ActiveRecord::Migration[4.2]
  def change
    enable_extension "hstore"
    add_column :users, :preferences, :hstore
    execute "CREATE INDEX index_users_on_preferences ON users USING BTREE(preferences);"
  end
end
