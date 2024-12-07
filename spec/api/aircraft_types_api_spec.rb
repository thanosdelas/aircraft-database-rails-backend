# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AircraftTypesAPI do
  include Rack::Test::Methods

  let(:endpoint_path) { '/api/aircraft-types' }
  let(:params) { {} }

  let!(:aircraft_a) do
    FactoryBot.create(:aircraft,
      model: 'Airbus Aircraft A Model',
      first_flight_year: 1956,
      manufacturers: ['Airbus', 'Antonov'],
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
      model: 'Antonov Aircraft C Model',
      first_flight_year: 1985
    )
  end

  describe 'GET /api/aircraft-types' do
    let(:params) { {} }
    let(:endpoint) { endpoint_path }

    it 'successfully fetches aircraft and responds with 200' do
      get endpoint, params

      expect(last_response.status).to eq(200)

      data = JSON.parse(last_response.body)['data']

      expect(data.length).to eq 8
      expect(data[0]['aircraft_type']).to eq 'Airliner'
      expect(data[0]['aircraft_count']).to eq 2

      expect(data[1]['aircraft_type']).to eq 'Business Jet'
      expect(data[1]['aircraft_count']).to eq 1

      current_index = 2
      AIRCRAFT_TYPES.each do |aircraft_type|
        next if ['Airliner', 'Business Jet'].include?(aircraft_type)

        expect(data[current_index]['aircraft_count']).to eq 0

        current_index += 1
      end
    end
  end
end
