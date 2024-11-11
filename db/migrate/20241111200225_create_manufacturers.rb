class CreateManufacturers < ActiveRecord::Migration[7.1]
  def change
    create_table :manufacturers do |t|
      t.string :manufacturer, index: { unique: true }, null: false
      t.string :description
      t.timestamps
    end
  end
end
