class CreateVenues < ActiveRecord::Migration[4.2]
  def change
    create_table :venues do |t|
      t.string :name
      t.string :abbreviation
      t.references :location, null: false

      t.timestamps
    end

    add_index :venues, ['location_id']
  end
end
