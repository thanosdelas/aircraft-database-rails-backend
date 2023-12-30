# frozen_string_literal: true

class AircraftAPI < Grape::API
  resource :aircraft do
    get do
      http_code = 200
      data = {
        status: 'ok',
        message: 'Sucessfully fetched images',
        data: ::Aircraft.all
      }

      render_response(http_code: http_code, data: data)
    end
  end
end
