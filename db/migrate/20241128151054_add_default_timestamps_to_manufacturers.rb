class AddDefaultTimestampsToManufacturers < ActiveRecord::Migration[7.1]
  def change
    change_column_default :manufacturers, :created_at, -> { 'CURRENT_TIMESTAMP' }
    change_column_default :manufacturers, :updated_at, -> { 'CURRENT_TIMESTAMP' }
  end
end
