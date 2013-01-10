class CreatePicks < ActiveRecord::Migration
  def change
    create_table :picks do |t|
      t.references :user, null: false
      t.references :festival, null: false
      t.references :film, null: false
      t.references :screening
      t.integer :priority
      t.integer :rating

      t.timestamps
    end

    add_index :picks, [:user_id, :festival_id, :film_id], unique: true
  end
end
