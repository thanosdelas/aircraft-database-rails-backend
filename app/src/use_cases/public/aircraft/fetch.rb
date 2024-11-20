# frozen_string_literal: true

module UseCases
  module Public
    module Aircraft
      class Fetch < ::UseCases::Base
        attr_reader :parameters, :data, :fields, :ids

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

        # NOTE: We could also use the following to get min, max year,
        #       but this implies that the columns does not have NULL sql values.
        #       aircraft.minimum(:first_flight_year)
        #       aircraft.maximum(:first_flight_year)
        def first_flight_year_bounds
          if @ids.length > 0
            year_min, year_max = ::Aircraft.where(id: @ids).pluck('MIN(first_flight_year) as year_min, MAX(first_flight_year) AS year_max').first
          else
            year_min, year_max = ::Aircraft.pluck('MIN(first_flight_year) as year_min, MAX(first_flight_year) AS year_max').first
          end

          {
            year_min: year_min,
            year_max: year_max
          }
        end

        def fetch_aircraft_by_manufacturer_from_model_field
          colelct_groups = []

          manufacturers = [
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
          ]

          manufacturers.each do |manufacturer|
            aircraft = ::Aircraft.select(@fields)
                                 .where(wikipedia_info_collected: true)
                                 .where('first_flight_year IS NOT NULL')
                                 .where('LOWER(model) LIKE :search_term', { search_term: "%#{::Aircraft.sanitize_sql_like(manufacturer.downcase)}%" })
                                 .order(model: :asc)
                                 .order(first_flight_year: :desc)

            colelct_groups += aircraft.to_a
          end

          # Collect all the rest that have first_flight_year
          aircraft = ::Aircraft.select(@fields)
                               .where(wikipedia_info_collected: true)
                               .where('first_flight_year IS NOT NULL')
                               .order(model: :asc)
                               .order(first_flight_year: :desc)

          manufacturers.each do |manufacturer|
            aircraft = aircraft.where('LOWER(model) NOT LIKE :search_term', { search_term: "%#{::Aircraft.sanitize_sql_like(manufacturer.downcase)}%" })
          end

          # Collect all the rest that do not have first_flight_year
          aircraft = ::Aircraft.select(@fields)
                               .where(wikipedia_info_collected: true)
                               .where('first_flight_year IS NULL')
                               .order(model: :asc)
                               .order(first_flight_year: :desc)

          manufacturers.each do |manufacturer|
            aircraft = aircraft.where('LOWER(model) NOT LIKE :search_term', { search_term: "%#{::Aircraft.sanitize_sql_like(manufacturer.downcase)}%" })
          end

          colelct_groups += aircraft.to_a

          colelct_groups
        end

        def fetch_aircraft
          aircraft = ::Aircraft.select(@fields)
                               .where(wikipedia_info_collected: true)
                               .order(first_flight_year: :desc)

          if @parameters.key?('manufacturer')
            aircraft = aircraft.joins(:manufacturers)
                               .where(manufacturers: { manufacturer: @parameters['manufacturer'] })

            @ids = aircraft.pluck(:id)

            aircraft = JSON.parse(
              ::Aircraft.includes(:manufacturers)
                        .includes(:types)
                        .includes(:images)
                        .where(id: ids)
                        .order(first_flight_year: :desc)
                        .to_json(include: [:manufacturers, :types, :images])
            )
          end

          if @parameters.key?('aircraft_type')
            aircraft = aircraft.joins(:types)
                               .where(types: { aircraft_type: @parameters['aircraft_type'] })

            @ids = aircraft.pluck(:id)

            aircraft = JSON.parse(
              ::Aircraft.includes(:types)
                        .includes(:images)
                        .where(id: ids)
                        .order(first_flight_year: :desc)
                        .to_json(include: [:types, :images])
            )
          end

          aircraft
        end
      end
    end
  end
end
