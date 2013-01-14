class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.references :festival, null: false
      t.references :user, null: false
      t.boolean :show_press, default: false

      t.timestamps
    end
    add_index :subscriptions, [:festival_id, :user_id], unique: true
  end
end
