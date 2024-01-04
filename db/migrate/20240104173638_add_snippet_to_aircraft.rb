class AddSnippetToAircraft < ActiveRecord::Migration[7.1]
  def change
    add_column :aircraft, :snippet, :string
  end
end
