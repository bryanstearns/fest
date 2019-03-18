class CreateFestivalLocations < ActiveRecord::Migration[4.2]
  def change
    create_table :festival_locations do |t|
      t.references :festival, null: false
      t.references :location, null: false
      t.timestamps
    end
  end
end
