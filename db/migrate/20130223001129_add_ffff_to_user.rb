class AddFfffToUser < ActiveRecord::Migration
  def change
    add_column :users, :ffff, :boolean, default: false
  end
end
