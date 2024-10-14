# frozen_string_literal: true

class AircraftAPI < Grape::API
  resource :aircraft do
    get do
      aircraft = ::Aircraft.select(:id, :model, :wikipedia_title, :featured_image)
                           .where(wikipedia_info_collected: true)

      http_code = 200
      data = {
        status: 'ok',
        message: 'Sucessfully fetched data',
        data: aircraft
      }

      render_response(http_code: http_code, data: data)
    end

    route_param :id do
      get do
        aircraft = JSON.parse(
          ::Aircraft.includes(:images).find_by(id: params[:id])
        .to_json(include: :images))

        http_code = 200
        data = aircraft

        render_response(http_code: http_code, data: data)
      end
    end
  end
end
