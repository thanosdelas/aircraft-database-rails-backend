class AddFirstFilghtClumnsToAircraft < ActiveRecord::Migration[7.1]
  def change
    add_column :aircraft, :first_flight_year, :integer
    add_column :aircraft, :first_flight, :date
    add_column :aircraft, :first_flight_raw, :string
  end
end
