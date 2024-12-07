class CreateManufacturerGroups < ActiveRecord::Migration[7.1]
  def change
    create_table :manufacturer_groups do |t|
      t.string :manufacturer_group, index: { unique: true }, null: false
      t.string :description
      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }
    end
  end
end
