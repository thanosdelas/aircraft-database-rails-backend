# frozen_string_literal: true

module UseCases
  module Public
    module Aircraft
      class Fetch < ::UseCases::Base
        attr_reader :parameters, :data, :fields, :ids

        MANUFACTURERS = [
          'Airbus',
          'Boeing',
          'Antonov',
          'Beechcraft',
          'Canadair',
          'Lockheed',
          'McDonnell',
          'North American',
          'Northrop',
          'Sukhoi',
          'Tupolev',
          'Beriev',
          'AgustaWestland'
        ].freeze

        def initialize(parameters:)
          super()

          @parameters = parameters

          # Initialize default variables
          @ids = []
          @fields = [
            :id,
            :model,
            :wikipedia_title,
            :featured_image,
            :first_flight_year
          ]
        end

        def dispatch(&response)
          if @parameters.key?('manufacturer') || @parameters.key?('aircraft_type')
            aircraft = fetch_aircraft
          else
            aircraft = fetch_aircraft_by_manufacturer_from_model_field
          end

          @data = {
            data: aircraft,
            metadata: {
              first_flight_year_bounds: first_flight_year_bounds
            }
          }

          success(&response)
        end

        private

        # NOTE: We could also use the following to get min, max year,
        #       but this implies that the columns does not have NULL sql values.
        #       aircraft.minimum(:first_flight_year)
        #       aircraft.maximum(:first_flight_year)
        def first_flight_year_bounds
          if @ids.length > 0
            year_min, year_max = ::Aircraft.where(id: @ids).pick('MIN(first_flight_year) as year_min, MAX(first_flight_year) AS year_max')
          else
            year_min, year_max = ::Aircraft.pick('MIN(first_flight_year) as year_min, MAX(first_flight_year) AS year_max')
          end

          {
            year_min: year_min,
            year_max: year_max
          }
        end

        # rubocop:disable Metrics/AbcSize
        def fetch_aircraft_by_manufacturer_from_model_field
          colelct_groups = []

          MANUFACTURERS.each do |manufacturer|
            aircraft = ::Aircraft.select(@fields)
                                 .where(wikipedia_info_collected: true)
                                 .where('LOWER(model) LIKE :search_term', { search_term: "%#{::Aircraft.sanitize_sql_like(manufacturer.downcase)}%" })
                                 .order(model: :asc)
                                 .order(first_flight_year: :desc)

            colelct_groups += aircraft.to_a
          end

          aircraft = ::Aircraft.select(@fields)
                               .where(wikipedia_info_collected: true)
                               .order(model: :asc)
                               .order(first_flight_year: :desc)

          MANUFACTURERS.each do |manufacturer|
            aircraft = aircraft.where('LOWER(model) NOT LIKE :search_term', { search_term: "%#{::Aircraft.sanitize_sql_like(manufacturer.downcase)}%" })
          end

          colelct_groups += aircraft.to_a

          colelct_groups
        end
        # rubocop:enable Metrics/AbcSize

        def fetch_aircraft
          aircraft = ::Aircraft.select(@fields)
                               .where(wikipedia_info_collected: true)
                               .order(first_flight_year: :desc)

          aircraft = by_type(aircraft) if @parameters.key?('aircraft_type')
          aircraft = by_manufacturer(aircraft) if @parameters.key?('manufacturer')

          aircraft
        end

        def by_type(aircraft)
          aircraft = aircraft.joins(:types)
                             .where(types: { aircraft_type: @parameters['aircraft_type'] })

          @ids = aircraft.pluck(:id)

          ::Aircraft
            .includes(:types)
            .includes(:manufacturers)
            .includes(:images)
            .where(id: ids)
            .order(first_flight_year: :desc)
        end

        def by_manufacturer(aircraft)
          aircraft = aircraft.joins(:manufacturers)
                             .where(manufacturers: { manufacturer: @parameters['manufacturer'] })

          @ids = aircraft.pluck(:id)

          ::Aircraft
            .includes(:manufacturers)
            .includes(:types)
            .includes(:images)
            .where(id: ids)
            .order(first_flight_year: :desc)
        end
      end
    end
  end
end
