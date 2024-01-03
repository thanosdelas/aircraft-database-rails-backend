# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::AircraftAPI do
  include Rack::Test::Methods

  let(:aircraft_id) { '111' }
  let(:aircraft) do
    ::Aircraft.new(id: aircraft_id, model: 'Test aircraft model')
  end

  let(:path) { '/api/admin/aircraft/images' }

  before do
    aircraft.save!
    authenticate_admin_user
  end

  describe 'PUT /api/admin/aircraft/images' do
    let(:params) { {} }
    let(:endpoint) { path }
    let(:images) do
      [
        {
          url: 'image/test_image_1',
          filename: 'test_image_1'
        },
        {
          url: 'image/test_image_2',
          filename: 'test_image_2'
        }
      ]
    end

    context 'when images can be updated' do
      let(:params) do
        {
          aircraft_id: aircraft_id,
          images: images
        }
      end

      context 'when no images exist' do
        it 'successfully updates images and responds with 200' do
          put endpoint, params

          expect(last_response.status).to eq(200)

          json = JSON.parse(last_response.body)

          updated_images = ::AircraftImage.all

          ids = json['data'].map { |entry| entry['id'] }
          expect(ids).to eq([updated_images[0].id, updated_images[1].id])

          expect(updated_images.count).to eq(2)
          expect(updated_images[0]).to have_attributes(
            url: images[0][:url],
            filename: images[0][:filename],
            aircraft_id: params[:aircraft_id].to_i
          )
          expect(updated_images[1]).to have_attributes(
            url: images[1][:url],
            filename: images[1][:filename],
            aircraft_id: params[:aircraft_id].to_i
          )
        end
      end

      context 'when some images exist but are not provided' do
        before do
          create_image = AircraftImage.new(
            aircraft_id: params[:aircraft_id],
            url: 'image/test_image_existing',
            filename: 'test_image_existing'
          )

          create_image.save!
        end

        it 'successfully deletes the non provided existing images and saves the provided images and responds with 200' do # rubocop:disable Layout/LineLength
          put endpoint, params

          expect(last_response.status).to eq(200)

          json = JSON.parse(last_response.body)

          updated_images = ::AircraftImage.all

          ids = json['data'].map { |entry| entry['id'] }
          expect(ids).to eq([updated_images[0].id, updated_images[1].id])

          expect(updated_images.count).to eq(2)
          expect(updated_images[0]).to have_attributes(
            url: images[0][:url],
            filename: images[0][:filename],
            aircraft_id: params[:aircraft_id].to_i
          )
          expect(updated_images[1]).to have_attributes(
            url: images[1][:url],
            filename: images[1][:filename],
            aircraft_id: params[:aircraft_id].to_i
          )
        end
      end
    end

    context 'when images cannot be updated' do
      let(:params) do
        {
          aircraft_id: aircraft_id,
          images: images
        }
      end

      context 'because at least one image is missing filename attribute' do
        let(:images) do
          [
            {
              url: 'image/test_image_1',
              filename: 'test_image_1'
            },
            {
              url: 'image/test_image_2'
            }
          ]
        end

        it 'does not update images and responds with 422' do
          put endpoint, params

          expect(last_response.status).to eq(422)
          expect(last_response.body).to eq({ status: 'failed', message: 'Could not update images' }.to_json)

          updated_images = ::AircraftImage.all
          expect(updated_images).to eq([])
        end
      end
    end
  end
end
