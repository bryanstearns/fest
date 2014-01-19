class AddAutoToPicks < ActiveRecord::Migration
  def change
    add_column :picks, :auto, :boolean, :default => false
  end
end
