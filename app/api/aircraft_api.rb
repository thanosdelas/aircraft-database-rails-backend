# frozen_string_literal: true

class AircraftAPI < Grape::API
  params do
    optional :aircraft_type, type: String
  end
  resource :aircraft do
    get do
      aircraft = ::Aircraft.select(:id, :model, :wikipedia_title, :featured_image)
                           .where(wikipedia_info_collected: true)

      if params.key?('aircraft_type')
        aircraft = aircraft.joins(:types).where(types: {aircraft_type: params['aircraft_type']})
      end

      data = {
        data: aircraft
      }

      render_response(status_code: :ok, data: data)
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
