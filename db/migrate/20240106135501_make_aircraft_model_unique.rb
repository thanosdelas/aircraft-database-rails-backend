class MakeAircraftModelUnique < ActiveRecord::Migration[7.1]
  def change
    add_index :aircraft, :model, name: :index_aircraft_on_model, unique: true
  end
end
