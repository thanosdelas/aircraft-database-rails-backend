# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AircraftManufacturersAPI do
  include Rack::Test::Methods

  let(:endpoint_path) { '/api/aircraft-manufacturers' }
  let(:params) { {} }

  let!(:aircraft_a) do
    FactoryBot.create(:aircraft,
      model: 'Airbus Aircraft A Model',
      first_flight_year: 1956,
      manufacturers: ['Airbus'],
      types: ['Airliner']
    )
  end
  let!(:aircraft_b) do
    FactoryBot.create(:aircraft,
      model: 'Boeing Aircraft B Model',
      first_flight_year: 1970,
      manufacturers: ['Boeing'],
      types: ['Airliner', 'Business Jet']
    )
  end
  let!(:aircraft_c) do
    FactoryBot.create(:aircraft,
      model: 'Airbus Aircraft C Model',
      first_flight_year: 1983,
      manufacturers: ['Airbus'],
      types: ['Airliner']
    )
  end
  let!(:aircraft_bell) do
    FactoryBot.create(:aircraft,
      model: 'Bell Aircraft Model',
      manufacturers: ['Bell Aircraft'],
      first_flight_year: 1976
    )
  end
  let!(:aircraft_helicopter) do
    FactoryBot.create(:aircraft,
      model: 'Bell Hellicopter Model',
      manufacturers: ['Bell Helicopter'],
      first_flight_year: 1976
    )
  end
  let!(:aircraft_beechcraft) do
    FactoryBot.create(:aircraft,
      model: 'Beechcraft Aircraft Model',
      first_flight_year: nil
    )
  end

  describe 'GET /api/aircraft-manufacturers' do
    let(:params) { {} }
    let(:endpoint) { endpoint_path }

    it 'successfully fetches aircraft and responds with 200' do
      get endpoint, params

      expect(last_response.status).to eq(200)

      data = JSON.parse(last_response.body)['data']

      expect(data.length).to eq 19
      expect(data[0]['manufacturer']).to eq 'Airbus'
      expect(data[0]['aircraft_count']).to eq 2
      expect(data[1]['manufacturer']).to eq 'Bell Helicopter'
      expect(data[1]['aircraft_count']).to eq 1
      expect(data[2]['manufacturer']).to eq 'Bell Aircraft'
      expect(data[2]['aircraft_count']).to eq 1
      expect(data[3]['manufacturer']).to eq 'Boeing'
      expect(data[3]['aircraft_count']).to eq 1

      current_index = 4
      MANUFACTURERS.each do |manufacturer|
        next if ['Airbus', 'Bell Helicopter', 'Bell Aircraft', 'Boeing'].include?(manufacturer)

        expect(data[current_index]['aircraft_count']).to eq 0

        current_index += 1
      end
    end
  end
end
