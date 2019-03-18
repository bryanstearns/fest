class AddAutoToPicks < ActiveRecord::Migration[4.2]
  def change
    add_column :picks, :auto, :boolean, :default => false
  end
end
