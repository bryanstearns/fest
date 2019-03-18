class CreateAnnouncements < ActiveRecord::Migration[4.2]
  def change
    create_table :announcements do |t|
      t.string :subject
      t.text :contents
      t.boolean :published, default: false
      t.datetime :published_at

      t.timestamps
    end
  end
end
