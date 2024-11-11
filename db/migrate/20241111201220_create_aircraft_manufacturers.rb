class CreateAircraftManufacturers < ActiveRecord::Migration[7.1]
  def change
    create_table :aircraft_manufacturers do |t|
      t.references :aircraft, foreign_key: { to_table: :aircraft }, null: false
      t.references :manufacturer, foreign_key: { to_table: :manufacturers }, null: false
      t.timestamps
    end

    add_index :aircraft_manufacturers, [:aircraft_id, :manufacturer_id], unique: true
  end
end
