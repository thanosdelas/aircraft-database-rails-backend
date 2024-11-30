class AddDefaultTimestampsToTypes < ActiveRecord::Migration[7.1]
  def change
    change_column_default :types, :created_at, -> { 'CURRENT_TIMESTAMP' }
    change_column_default :types, :updated_at, -> { 'CURRENT_TIMESTAMP' }
  end
end
