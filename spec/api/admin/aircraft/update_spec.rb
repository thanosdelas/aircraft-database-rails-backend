# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::AircraftAPI do
  include Rack::Test::Methods

  let(:aircraft_id) { '111' }
  let(:aircraft) do
    ::Aircraft.new(id: aircraft_id, model: 'Test aircraft model')
  end

  let(:path) { "/api/admin/aircraft/#{aircraft_id}" }

  before do
    aircraft.save!
    authenticate_admin_user
  end

  describe 'PUT /api/admin/aircraft/images' do
    let(:params) { {} }
    let(:endpoint) { path }

    context 'when aircraft can be updated' do
      let(:params) do
        {
          model: 'Test model name',
          description: 'Test aircraft description'
        }
      end

      context 'when aircraft details can be updated' do
        it 'successfully updates aircraft and responds with 200' do
          put endpoint, params

          expect(last_response.status).to eq(200)

          expect do
            aircraft.reload
          end.to change { aircraft.model }.from('Test aircraft model').to(params[:model])
             .and change { aircraft.description }.from(nil).to(params[:description])

          json = JSON.parse(last_response.body)
          expect(json['data'].count).to eq(1)
          expect(json['data'][0]['model']).to eq(params[:model])
          expect(json['data'][0]['description']).to eq(params[:description])
        end
      end
    end
  end
end
