# frozen_string_literal: true

module UseCases
  module API
    module Admin
      module Aircraft
        module Images
          class Fetch < ::UseCases::API::Base
            def initialize(aircraft_id:)
              super()

              @aircraft_id = aircraft_id
            end

            def dispatch(&response)
              if !verify_aircraft_id? || !verify_aircraft_exists?
                @http_code = 422 # Maybe 204 or 404?
                add_error(code: :failed, message: 'Could not fetch images')

                return error(&response)
              end

              @http_code = 200
              @message = 'Sucessfully fetched images'
              @response_data = ::AircraftImage.where(aircraft_id: @aircraft_id)
              success(&response)
            end

            private

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
