class CreateAircraftTypes < ActiveRecord::Migration[7.1]
  def change
    create_table :aircraft_types do |t|
      t.references :aircraft, foreign_key: { to_table: :aircraft }, null: false
      t.references :type, foreign_key: { to_table: :types }, null: false
      t.timestamps
    end

    add_index :aircraft_types, [:aircraft_id, :type_id], unique: true
  end
end
