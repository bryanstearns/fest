class AddFfffToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :ffff, :boolean, default: false
  end
end
