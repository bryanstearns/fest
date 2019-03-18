class CreateActivity < ActiveRecord::Migration[4.2]
  def change
    create_table :activity do |t|
      t.string :name
      t.references :user, null: false
      t.references :festival
      t.references :subject, polymorphic: true
      t.references :target, polymorphic: true
      t.text :details
      t.timestamps
    end unless table_exists?(:activity)
  end
end
