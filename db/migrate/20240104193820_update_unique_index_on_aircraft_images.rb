class UpdateUniqueIndexOnAircraftImages < ActiveRecord::Migration[7.1]
  def change
    remove_index :aircraft_images, name: :index_aircraft_images_on_url
    add_index :aircraft_images, [:aircraft_id, :url], name: :index_aircraft_images_on_url_and_aircraft_id, unique: true
  end
end
