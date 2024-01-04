class MakeModelNotNullInAircraft < ActiveRecord::Migration[7.1]
  def change
    change_column :aircraft, :model, :string, null: false
  end
end
