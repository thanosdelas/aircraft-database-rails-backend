# frozen_string_literal: true

module UseCases
  module Public
    module Aircraft
      class Manufacturer < ::UseCases::Base
        attr_reader :parameters, :grouped, :data

        def initialize(parameters:)
          super()

          @parameters = parameters

          @grouped = false
          @grouped = true if parameters.key?('grouped')
        end

        def dispatch(&response)
          if @grouped == true
            manufacturers = fetch_grouped
          else
            manufacturers = fetch_flat
          end

          @data = {
            data: manufacturers
          }

          success(&response)
        end

        private

        def fetch_flat
          ::Manufacturer.select('
              manufacturers.id,
              manufacturers.manufacturer,
              COUNT(aircraft_manufacturers.aircraft_id) AS aircraft_count
            ')
            .left_joins(:aircraft_manufacturers)
            .group('manufacturers.id')
            .order('aircraft_count DESC')
        end

        def fetch_grouped
          ::ManufacturerGroup.select('
              manufacturer_groups.id,
              manufacturer_groups.manufacturer_group,
              (
                SELECT COUNT(manufacturers.manufacturer)
                FROM manufacturers
                WHERE manufacturer_group_id = manufacturer_groups.id
              ) AS manufacturer_count,
              (
                SELECT COUNT(aircraft_manufacturers.aircraft_id)
                FROM manufacturers
                LEFT JOIN aircraft_manufacturers ON aircraft_manufacturers.manufacturer_id = manufacturers.id
                WHERE manufacturers.manufacturer_group_id = manufacturer_groups.id
              ) AS aircraft_count
            ')
            .order('aircraft_count DESC')
        end
      end
    end
  end
end
