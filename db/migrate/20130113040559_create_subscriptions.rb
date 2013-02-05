class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.references :festival, null: false
      t.references :user, null: false
      t.boolean :show_press, default: false
      t.text :restriction_text
      t.string :excluded_location_ids
      t.string :key, limit: 10

      t.timestamps
    end
    add_index :subscriptions, [:festival_id, :user_id], unique: true
  end
end
