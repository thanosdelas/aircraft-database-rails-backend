class RemoveUniqueFilenameOnAircraftImages < ActiveRecord::Migration[7.1]
  def change
    remove_index :aircraft_images, name: :index_aircraft_images_on_filename
    add_index :aircraft_images, :filename, name: :index_aircraft_images_on_filename
  end
end
