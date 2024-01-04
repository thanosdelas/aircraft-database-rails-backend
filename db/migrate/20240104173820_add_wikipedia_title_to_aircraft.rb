class AddWikipediaTitleToAircraft < ActiveRecord::Migration[7.1]
  def change
    add_column :aircraft, :wikipedia_title, :string
  end
end
