# frozen_string_literal: true

class AircraftTypesAPI < Grape::API
  resource :'aircraft-types' do
    get do
      # sql_query = "
      #   SELECT
      #     types.id,
      #     types.aircraft_type,
      #     COUNT(aircraft_types.aircraft_id) AS aircraft_count
      #   FROM types
      #   LEFT JOIN aircraft_types ON aircraft_types.type_id = types.id
      #   GROUP BY types.id
      #   ORDER BY aircraft_count DESC
      # "
      aircraft_types = ::Type
        .select('
          types.id,
          types.aircraft_type,
          COUNT(aircraft_types.aircraft_id) AS aircraft_count'
        )
        .left_joins(:aircraft_types)
        .group('types.id')
        .order('aircraft_count DESC')

      data = {
        data: aircraft_types
      }

      render_response(status_code: :ok, data: data)
    end
  end
end
