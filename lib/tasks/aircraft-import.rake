# frozen_string_literal: true

namespace :aircraft do
  require_relative './data/data.rb'

  desc "Import data from opensky network aircraft database"
  task opensky_network: :environment do
    abort "\n\n[*]Deprecated\n\n"

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

  desc "Import a small sample of aircraft models for testing"
  task import_test_data: :environment do
    ::AircraftImage.delete_all
    ::Aircraft.delete_all

    aircraft_models = AIRCRAFT_MODELS.first

    aircraft_models.each do |entry|
      row = Aircraft.new(model: entry)
      row.save
    end

    puts "\nDone"
  end

  desc "Import aircraft models"
  task import_aircraft_models: :environment do
    ::AircraftImage.delete_all
    ::Aircraft.delete_all

    AIRCRAFT_MODELS.each do |entry|
      row = Aircraft.new(model: entry)
      row.save
    end

    puts "\nDone"
  end

  desc "Update aircraft models"
  task update_aircraft_models: :environment do
    created = 0

    AIRCRAFT_MODELS.each do |entry|
      existing_aircraft = ::Aircraft.find_by(model: entry)

      next if existing_aircraft != nil

      row = Aircraft.new(model: entry)
      row.save!

      created = created + 1
    end

    puts "Done. Created #{created} aircraft"
  end
end
