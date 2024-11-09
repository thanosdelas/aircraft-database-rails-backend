class CreateTypes < ActiveRecord::Migration[7.1]
  def change
    create_table :types do |t|
      t.string :aircraft_type, index: { unique: true }, null: false
      t.string :description
      t.timestamps
    end
  end
end
