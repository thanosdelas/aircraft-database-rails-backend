class AddInfoboxColumnsToAircraft < ActiveRecord::Migration[7.1]
  def change
    add_column :aircraft, :infobox_json, :string, null: true
    add_column :aircraft, :infobox_raw, :string, null: true
  end
end
