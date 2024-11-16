# frozen_string_literal: true

class AircraftAPI < Grape::API
  params do
    optional :aircraft_type, type: String
  end
  resource :aircraft do
    get do
      response = ::UseCases::Public::Aircraft::Fetch.new(parameters: params)
      response.dispatch do |status_code, data|
        render_response(status_code: status_code, data: data)
      end
    end

    route_param :id do
      get do
        aircraft = JSON.parse(
          ::Aircraft.includes(:types)
                    .includes(:images)
                    .find_by(id: params[:id])
                    .to_json(include: [:types, :images])
        )

        render_response(status_code: :ok, data: aircraft)
      end
    end
  end
end
