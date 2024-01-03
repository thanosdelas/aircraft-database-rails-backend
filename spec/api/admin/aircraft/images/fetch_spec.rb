# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::AircraftAPI do
  include Rack::Test::Methods

  let(:aircraft_id) { '111' }
  let(:aircraft) do
    ::Aircraft.new(id: aircraft_id, model: 'Test aircraft model')
  end

  let(:images) do
    [
      {
        url: 'image/test_image_1',
        title: 'test_image_1'
      },
      {
        url: 'image/test_image_2',
        title: 'test_image_2'
      }
    ]
  end

  let(:path) { '/api/admin/aircraft/images' }

  before do
    aircraft.save!
    authenticate_admin_user

    images.each do |image|
      AircraftImage.new(
        aircraft_id: params[:aircraft_id],
        url: image[:url],
        filename: image[:title]
      ).save!
    end
  end

  describe 'GET /api/admin/aircraft/images' do
    let(:endpoint) { path }

    let(:params) do
      {
        aircraft_id: aircraft_id
      }
    end

    it 'successfully retrieves all aircraft images' do
      get endpoint, params

      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)

      expect(json['data'].count).to eq(2)

      urls = json['data'].map { |entry| entry[:url] }
      expect(urls).to eq([images[0]['url'], images[1]['url']])
    end
  end
end
