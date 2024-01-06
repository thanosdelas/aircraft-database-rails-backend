# frozen_string_literal: true

class AircraftAPI < Grape::API
  resource :aircraft do
    get do
      aircraft = JSON.parse(
        ::Aircraft.includes(:images).where(wikipedia_info_collected: true)
      .to_json(include: :images))

      http_code = 200
      data = {
        status: 'ok',
        message: 'Sucessfully fetched images',
        data: aircraft
      }

      render_response(http_code: http_code, data: data)
    end
  end
end
