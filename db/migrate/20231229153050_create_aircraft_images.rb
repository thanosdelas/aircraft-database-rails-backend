class CreateAircraftImages < ActiveRecord::Migration[7.1]
  def change
    create_table :aircraft_images do |t|
      t.string :url, index: { unique: true }, null: false
      t.string :filename, index: { unique: true }, null: false
      t.string :description
      t.references :aircraft, foreign_key: { to_table: :aircraft }, null: false
      t.timestamps
    end
  end
end
