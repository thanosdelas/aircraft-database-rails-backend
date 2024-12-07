# frozen_string_literal: true

class AircraftManufacturersAPI < Grape::API
  resource :'aircraft-manufacturers' do
    get do
      response = ::UseCases::Public::Aircraft::Manufacturer.new(parameters: params)
      response.dispatch do |status_code, data|
        render_response(status_code: status_code, data: data)
      end
    end
  end
end
