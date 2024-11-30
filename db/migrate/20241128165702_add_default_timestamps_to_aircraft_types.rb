class AddDefaultTimestampsToAircraftTypes < ActiveRecord::Migration[7.1]
  def change
    change_column_default :aircraft_types, :created_at, -> { 'CURRENT_TIMESTAMP' }
    change_column_default :aircraft_types, :updated_at, -> { 'CURRENT_TIMESTAMP' }
  end
end
