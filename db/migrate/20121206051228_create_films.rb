class CreateFilms < ActiveRecord::Migration
  def change
    create_table :films do |t|
      t.references :festival, null: false
      t.string :name
      t.string :sort_name
      t.text :description
      t.string :url_fragment
      t.integer :duration
      t.string :countries
      t.float :page
      t.timestamps
    end

    add_index :films, [:festival_id, :name], unique: true
    add_index :films, [:festival_id, :page, :name]
  end
end
