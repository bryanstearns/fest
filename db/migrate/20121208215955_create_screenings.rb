class CreateScreenings < ActiveRecord::Migration[4.2]
  def change
    create_table :screenings do |t|
      t.references :festival, null: false
      t.references :film, null: false
      t.references :venue, null: false
      t.references :location, null: false
      t.datetime :starts_at
      t.datetime :ends_at
      t.boolean :press, default: false

      t.timestamps
    end

    add_index :screenings, [:festival_id, :starts_at, :press]
    add_index :screenings, [:film_id, :starts_at, :press]
  end
end
