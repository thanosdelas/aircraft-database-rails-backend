# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AircraftTypesAPI do
  include Rack::Test::Methods

  let(:endpoint_path) { '/api/aircraft-types' }

  let(:aircraft_types) do
    [
      'Business Jet',
      'Utility Helicopter',
      'Multirole Combat Aircraft',
      'Fighter Aircraft',
      'Transport',
      'Airliner',
      'Unmanned Combat Aerial Vehicle'
    ]
  end

  let(:aircraft_a) do
    ::Aircraft.new(
      model: 'Test aircraft model A'
    )
  end

  let(:aircraft_b) do
    ::Aircraft.new(
      model: 'Test aircraft model B'
    )
  end

  let(:aircraft_c) do
    ::Aircraft.new(
      model: 'Test aircraft model C'
    )
  end

  before do
    aircraft_types_created = []

    aircraft_types.each do |type|
      aircraft_type = ::Type.new(aircraft_type: type)
      aircraft_type.save!

      aircraft_types_created.push(aircraft_type)
    end

    aircraft_a.types.push(aircraft_types_created[0])
    aircraft_a.types.push(aircraft_types_created[4])
    aircraft_b.types.push(aircraft_types_created[4])
    aircraft_c.types.push(aircraft_types_created[4])

    aircraft_a.save!
    aircraft_b.save!
    aircraft_c.save!
  end

  describe 'GET /api/aircraft-types' do
    let(:params) { {} }
    let(:endpoint) { endpoint_path }

    it 'successfully fetches aircraft and responds with 200' do
      get endpoint, params

      expect(last_response.status).to eq(200)

      data = JSON.parse(last_response.body)['data']

      expect(data.length).to eq 7
      expect(data[0]['aircraft_type']).to eq 'Transport'
      expect(data[0]['aircraft_count']).to eq 3

      expect(data[1]['aircraft_type']).to eq 'Business Jet'
      expect(data[1]['aircraft_count']).to eq 1
    end
  end
end
