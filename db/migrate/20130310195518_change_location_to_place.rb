class ChangeLocationToPlace < ActiveRecord::Migration
  def change
    rename_column :festivals, :location, :place
    add_column :locations, :place, :string

    Location.reset_column_information
    Location.find_each do |location|
      festival = location.festivals.first
      location.place = festival.place
      puts "Location '#{location.name}' is in '#{location.place}' now."
      location.save!
    end
  end
end
