class AddWikipediaInfoCollectedOnAircraft < ActiveRecord::Migration[7.1]
  def change
    add_column :aircraft, :wikipedia_info_collected, :boolean, default: false
  end
end
