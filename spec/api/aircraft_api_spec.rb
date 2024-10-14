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

  before do
    aircraft_a.images.new(images)

    aircraft_a.save!
    aircraft_b.save!
  end

  describe 'GET /api/aircraft' do
    let(:params) { {} }
    let(:endpoint) { path }

    it 'successfully fetches aircraft and responds with 201' do
      get endpoint, params

      json = JSON.parse(last_response.body)
      expect(json['data'].length).to eq 1
      expect(json['data'][0]['model']).to eq 'Test aircraft model A'
      expect(json['data'][0]['wikipedia_title']).to eq 'Test aircraft model A wikipedia title'
      expect(json['data'][0]['featured_image']).to eq nil
    end
  end

  describe 'GET /api/aircraft/:id' do
    let(:params) { {} }
    let(:endpoint) { "#{path}/#{aircraft_a.id}" }

    it 'successfully fetches aircraft and responds with 201' do
      get endpoint, params

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
