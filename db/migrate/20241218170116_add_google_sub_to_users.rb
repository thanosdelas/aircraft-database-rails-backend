class AddGoogleSubToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :google_sub, :string, default: nil, null: true
    add_index :users, :google_sub, unique: true
  end
end
