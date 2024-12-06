# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AircraftAPI do
  include Rack::Test::Methods

  let(:path) { '/api/aircraft' }
  let(:params) { {} }

  let(:images) do
    [
      {
        filename: 'test_image_filename_a.jpg',
        url: 'example.com/test_image_filename_a.jpg'
      },
      {
        filename: 'test_image_filename_b.jpg',
        url: 'example.com/test_image_filename_b.jpg'
      }
    ]
  end

  let!(:aircraft_a) do
    FactoryBot.create(:aircraft,
      model: 'Airbus Aircraft A Model',
      first_flight_year: 1956,
      images: images,
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

  describe 'GET /api/aircraft' do
    let(:params) { {} }
    let(:endpoint) { path }

    context 'when no parameters are provided' do
      it 'successfully fetches aircraft and responds with 200' do
        get endpoint, params

        expect(last_response.status).to eq(200)

        json = JSON.parse(last_response.body)
        expect(json['data'].length).to eq 3
        expect(json['data'][0]['model']).to eq 'Airbus Aircraft A Model'
        expect(json['data'][1]['model']).to eq 'Boeing Aircraft B Model'
        expect(json['data'][2]['model']).to eq 'Antonov Aircraft C Model'
      end
    end

    context 'when aircraft_type parameter is provided' do
      let(:params) do
        {
          aircraft_type: 'Airliner'
        }
      end

      it 'successfully filters aircraft and responds with 200' do
        get endpoint, params

        expect(last_response.status).to eq(200)

        json = JSON.parse(last_response.body)
        expect(json['data'].length).to eq 2
        expect(json['data'][0]['model']).to eq 'Boeing Aircraft B Model'
        expect(json['data'][1]['model']).to eq 'Airbus Aircraft A Model'
      end
    end
  end

  describe 'GET /api/aircraft/:id' do
    let(:params) { {} }
    let(:endpoint) { "#{path}/#{aircraft_a.id}" }

    it 'successfully fetches aircraft and responds with 200' do
      get endpoint, params

      expect(last_response.status).to eq(200)

      json = JSON.parse(last_response.body)
      expect(json['model']).to eq 'Airbus Aircraft A Model'
      expect(json['images'].length).to eq 2
      expect(json['images'][0]['filename']).to eq 'test_image_filename_a.jpg'
      expect(json['images'][0]['url']).to eq 'example.com/test_image_filename_a.jpg'
      expect(json['images'][1]['filename']).to eq 'test_image_filename_b.jpg'
      expect(json['images'][1]['url']).to eq 'example.com/test_image_filename_b.jpg'
    end
  end
end
