# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AircraftAPI do
  include Rack::Test::Methods

  let(:aircraft_a) do
    ::Aircraft.new(
      model: 'Test aircraft model A',
      wikipedia_title: 'Test aircraft model A wikipedia title',
      wikipedia_info_collected: true
    )
  end

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

  let(:aircraft_b) do
    ::Aircraft.new(
      model: 'Test aircraft model B',
      wikipedia_info_collected: false
    )
  end

  let(:path) { '/api/aircraft' }

  describe 'GET /api/aircraft' do
    let(:params) { {} }
    let(:endpoint) { path }

    context 'when no parameters are provided' do
      before do
        aircraft_a.save!
        aircraft_b.save!
      end

      it 'successfully fetches aircraft and responds with 200' do
        get endpoint, params

        expect(last_response.status).to eq(200)

        json = JSON.parse(last_response.body)
        expect(json['data'].length).to eq 1
        expect(json['data'][0]['model']).to eq 'Test aircraft model A'
        expect(json['data'][0]['wikipedia_title']).to eq 'Test aircraft model A wikipedia title'
        expect(json['data'][0]['featured_image']).to eq nil
      end
    end

    context 'when aircraft_type parameter is provided' do
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
          model: 'Test aircraft model A',
          wikipedia_info_collected: true
        )
      end

      let(:aircraft_b) do
        ::Aircraft.new(
          model: 'Test aircraft model B',
          wikipedia_info_collected: true
        )
      end

      let(:aircraft_c) do
        ::Aircraft.new(
          model: 'Test aircraft model C',
          wikipedia_info_collected: true
        )
      end

      let(:params) do
        {
          aircraft_type: 'Transport',
          wikipedia_info_collected: true
        }
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
        aircraft_b.types.push(aircraft_types_created[1])
        aircraft_c.types.push(aircraft_types_created[4])

        aircraft_a.save!
        aircraft_b.save!
        aircraft_c.save!
      end

      it 'successfully filters aircraft and responds with 200' do
        get endpoint, params

        expect(last_response.status).to eq(200)

        json = JSON.parse(last_response.body)
        expect(json['data'].length).to eq 2
        expect(json['data'][0]['model']).to eq 'Test aircraft model A'
        expect(json['data'][1]['model']).to eq 'Test aircraft model C'
      end
    end
  end

  describe 'GET /api/aircraft/:id' do
    let(:params) { {} }
    let(:endpoint) { "#{path}/#{aircraft_a.id}" }

    before do
      aircraft_a.images.new(images)

      aircraft_a.save!
      aircraft_b.save!
    end

    it 'successfully fetches aircraft and responds with 200' do
      get endpoint, params

      expect(last_response.status).to eq(200)

      json = JSON.parse(last_response.body)
      expect(json['model']).to eq 'Test aircraft model A'
      expect(json['wikipedia_title']).to eq 'Test aircraft model A wikipedia title'
      expect(json['featured_image']).to eq nil
      expect(json['images'].length).to eq 2
      expect(json['images'][0]['filename']).to eq 'test_image_filename_a.jpg'
      expect(json['images'][0]['url']).to eq 'example.com/test_image_filename_a.jpg'
      expect(json['images'][1]['filename']).to eq 'test_image_filename_b.jpg'
      expect(json['images'][1]['url']).to eq 'example.com/test_image_filename_b.jpg'
    end
  end
end
