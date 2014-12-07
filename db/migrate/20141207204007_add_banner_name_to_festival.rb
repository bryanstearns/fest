class AddBannerNameToFestival < ActiveRecord::Migration
  def change
    add_column :festivals, :banner_name, :string, default: '', null: false
  end
end
