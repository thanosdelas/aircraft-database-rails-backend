# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::AircraftAPI do
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

  let(:path) { "/api/admin/aircraft" }

  before do
    aircraft_a.images.new(images)
    aircraft_a.save!
    aircraft_b.save!
    authenticate_admin_user
  end

  describe 'GET /api/admin/aircraft/images' do
    let(:params) { {} }
    let(:endpoint) { path }

    it 'successfully fetches aircraft and responds with 200' do
      get endpoint, params

      json = JSON.parse(last_response.body)
      expect(json['data'].length).to eq 2
      expect(json['data'][0]['model']).to eq 'Test aircraft model A'
      expect(json['data'][0]['wikipedia_title']).to eq 'Test aircraft model A wikipedia title'
      expect(json['data'][0]['featured_image']).to eq nil
      expect(json['data'][1]['model']).to eq 'Test aircraft model B'
      expect(json['data'][1]['wikipedia_title']).to eq nil
      expect(json['data'][1]['featured_image']).to eq nil
    end
  end
end
