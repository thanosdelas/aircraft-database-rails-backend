# frozen_string_literal: true

module Admin
  class AircraftAPI < Grape::API
    resource :aircraft do
      get do
        Aircraft.all
      end

      params do
        requires :aircraft_id, type: String
        requires :images, type: Array
      end
      put 'images' do
        response = ::UseCases::API::Admin::Aircraft::Images::Update.new(
          aircraft_id: params[:aircraft_id],
          images: params[:images]
        )

        response.dispatch do |http_code, data|
          render_response(http_code: http_code, data: data)
        end
      end
    end
  end
end
