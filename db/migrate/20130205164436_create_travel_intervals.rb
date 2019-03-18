class CreateTravelIntervals < ActiveRecord::Migration[4.2]
  def change
    create_table :travel_intervals do |t|
      t.references :from_location, null: false
      t.references :to_location, null: false
      t.references :user
      t.integer :seconds_from
      t.integer :seconds_to

      t.timestamps
    end
  end
end
