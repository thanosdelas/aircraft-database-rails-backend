class AddDefaultTimestampsToAircraftManufacturers < ActiveRecord::Migration[7.1]
  def change
    change_column_default :aircraft_manufacturers, :created_at, -> { 'CURRENT_TIMESTAMP' }
    change_column_default :aircraft_manufacturers, :updated_at, -> { 'CURRENT_TIMESTAMP' }
  end
end
