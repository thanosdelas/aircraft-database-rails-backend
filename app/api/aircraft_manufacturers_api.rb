# frozen_string_literal: true

class AircraftManufacturersAPI < Grape::API
  resource :'aircraft-manufacturers' do
    get do
      aircraft_manufacturers = ::Manufacturer.select('
          manufacturers.id,
          manufacturers.manufacturer,
          COUNT(aircraft_manufacturers.aircraft_id) AS aircraft_manufacturer_count
        ')
        .left_joins(:aircraft_manufacturers)
        .group('manufacturers.id')
        .order('aircraft_manufacturer_count DESC')

      data = {
        data: aircraft_manufacturers
      }

      render_response(status_code: :ok, data: data)
    end
  end
end
