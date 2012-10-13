class CreateFestivals < ActiveRecord::Migration
  def change
    create_table :festivals do |t|
      t.string :slug
      t.string :slug_group
      t.string :name
      t.string :location
      t.string :main_url
      t.string :updates_url
      t.date :starts_on
      t.date :ends_on
      t.boolean :public
      t.boolean :scheduled
      t.datetime :revised_at

      t.timestamps
    end
    add_index :festivals, :slug, :unique => true
    add_index :festivals, :slug_group
  end
end
