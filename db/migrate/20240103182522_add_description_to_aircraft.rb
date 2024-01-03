class AddDescriptionToAircraft < ActiveRecord::Migration[7.1]
  def change
    add_column :aircraft, :description, :string
  end
end
