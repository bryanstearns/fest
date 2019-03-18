class CreateFestivals < ActiveRecord::Migration[4.2]
  def change
    create_table :festivals do |t|
      t.string :slug, null: false
      t.string :slug_group, null: false
      t.string :name, null: false
      t.string :location, null: false
      t.string :main_url
      t.string :updates_url
      t.date :starts_on
      t.date :ends_on
      t.boolean :published, default: false
      t.boolean :scheduled, default: false
      t.datetime :revised_at
      t.timestamps
    end
    add_index :festivals, :slug, :unique => true
    add_index :festivals, [:slug, :published]
    add_index :festivals, [:ends_on, :published]
    add_index :festivals, [:slug_group, :published]
  end
end
