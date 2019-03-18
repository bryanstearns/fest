class AddBannerNameToFestival < ActiveRecord::Migration[4.2]
  def change
    add_column :festivals, :banner_name, :string, default: '', null: false
  end
end
