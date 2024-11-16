# frozen_string_literal: true

module UseCases
  module Public
    module Aircraft
      class Fetch < ::UseCases::Base
        attr_reader :parameters, :data

        def initialize(parameters:)
          super()

          @parameters = parameters
        end

        def dispatch(&response)
          if @parameters.key?('manufacturer') || @parameters.key?('aircraft_type')
            aircraft = fetchAircraft
          else
            aircraft = fetchAircraftByManufacturerFromModelField
          end

          @data = { data: aircraft }

          success(&response)
        end

        def fetchAircraftByManufacturerFromModelField
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
            'AgustaWestland',
          ]

          manufacturers.each do |manufacturer|
            aircraft = ::Aircraft.select(:id, :model, :wikipedia_title, :featured_image)
                                 .where(wikipedia_info_collected: true)
                                 .where("LOWER(model) LIKE :search_term", { search_term: "%#{::Aircraft.sanitize_sql_like(manufacturer.downcase)}%"})
                                 .order(model: :asc)

            colelct_groups += aircraft.to_a
          end

          # Collect all the rest
          aircraft = ::Aircraft.select(:id, :model, :wikipedia_title, :featured_image)
                               .where(wikipedia_info_collected: true)
                               .order(model: :asc)

          manufacturers.each do |manufacturer|
            aircraft = aircraft.where("LOWER(model) NOT LIKE :search_term", { search_term: "%#{::Aircraft.sanitize_sql_like(manufacturer.downcase)}%"})
          end

          colelct_groups += aircraft.to_a

          colelct_groups
        end

        def fetchAircraft
          aircraft = ::Aircraft.select(:id, :model, :wikipedia_title, :featured_image)
                               .where(wikipedia_info_collected: true)
                               .order(model: :asc)

          if @parameters.key?('manufacturer')
            aircraft = aircraft.joins(:manufacturers)
                               .where(manufacturers: { manufacturer: @parameters['manufacturer'] })


            ids = aircraft.pluck(:id)

            aircraft = JSON.parse(
              ::Aircraft.includes(:manufacturers)
                        .includes(:types)
                        .includes(:images)
                        .where(id: ids)
                        .to_json(include: [:manufacturers, :types, :images])
            )
          end

          if @parameters.key?('aircraft_type')
            aircraft = aircraft.joins(:types)
                               .where(types: { aircraft_type: @parameters['aircraft_type'] })


            ids = aircraft.pluck(:id)

            aircraft = JSON.parse(
              ::Aircraft.includes(:types)
                        .includes(:images)
                        .where(id: ids)
                        .to_json(include: [:types, :images])
            )
          end

          aircraft
        end
      end
    end
  end
end
