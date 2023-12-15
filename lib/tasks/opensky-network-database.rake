namespace :opensky_network do
  desc "Import data from opensky network aircraft database"
  task import: :environment do
    require 'csv'

    csv_file = "#{Rails.root}/tmp/data/aircraftDatabase.csv"

    counter = 0
    collect_rows = []

    first = OpenskyNetworkRaw.first

    OpenskyNetworkRaw.delete_all

    puts "\nImporting ... "
    CSV.foreach(csv_file, headers: true) do |row|
      counter = counter + 1

      row = OpenskyNetworkRaw.new(row.to_hash)

      row.save

      break if counter == 10000
    end
    puts "\nDone"
  end
end
