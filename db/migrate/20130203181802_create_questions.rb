class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.string :email
      t.text :question
      t.boolean :acknowledged, default: false
      t.boolean :done, default: false

      t.timestamps
    end
  end
end
