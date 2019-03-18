class AddHasPressToFestivals < ActiveRecord::Migration[4.2]
  def change
    add_column :festivals, :has_press, :boolean, default: false
    Festival.reset_column_information
    Festival.where(slug_group: 'piff').update_all(has_press: true)
  end
end
