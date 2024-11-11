class AddWikipediaPageIdToAircraft < ActiveRecord::Migration[7.1]
  def change
    add_column :aircraft, :wikipedia_page_id, :string, null: true

    add_index :aircraft, :wikipedia_page_id, unique: true
  end
end
