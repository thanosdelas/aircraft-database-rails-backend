# frozen_string_literal: true

module UseCases
  module API
    module Admin
      module Aircraft
        module Images
          class Fetch
            def initialize(aircraft_id:)
              @aircraft_id = aircraft_id
            end

            def dispatch(&response)
              return error(&response) if !verify_aircraft_id? ||
                                         !verify_aircraft_exists?

              success(&response)
            end

            private

            def success
              http_code = 200
              data = {
                status: 'ok',
                message: 'Sucessfully fetched images',
                data: ::AircraftImage.where(aircraft_id: @aircraft_id)
              }

              yield http_code, data
            end

            def error
              http_code = 422
              data = {
                status: 'failed',
                message: 'Could not fetch images'
              }

              yield http_code, data
            end

            def verify_aircraft_id?
              return true if @aircraft_id.present?

              false
            end

            def verify_aircraft_exists?
              @aircraft = ::Aircraft.find_by(id: @aircraft_id)

              return false if @aircraft.nil?

              true
            end
          end
        end
      end
    end
  end
end
