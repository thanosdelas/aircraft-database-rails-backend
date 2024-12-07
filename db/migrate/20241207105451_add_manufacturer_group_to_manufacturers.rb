class AddManufacturerGroupToManufacturers < ActiveRecord::Migration[7.1]
  def change
    add_reference :manufacturers, :manufacturer_group, foreign_key: true
  end
end
