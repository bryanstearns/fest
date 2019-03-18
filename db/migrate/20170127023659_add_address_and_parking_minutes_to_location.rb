class AddAddressAndParkingMinutesToLocation < ActiveRecord::Migration[4.2]
  def change
    add_column :locations, :address, :string
    add_column :locations, :parking_minutes, :integer, default: 10, null: false
  end
end
