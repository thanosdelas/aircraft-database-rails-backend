# frozen_string_literal: true

module UseCases
  module Admin
    module Aircraft
      module Images
        class Fetch < ::UseCases::Base
          def initialize(aircraft_id:)
            super()

            @aircraft_id = aircraft_id
          end

          def dispatch(&response)
            return error(&response) if !verify_aircraft_id? || !verify_aircraft_exists?

            @data = ::AircraftImage.where(aircraft_id: @aircraft_id)
            success(&response)
          end

          private

          def verify_aircraft_id?
            return true if @aircraft_id.present?

            add_error(code: :failed, message: 'Could not fetch images. No id Provided.')
            false
          end

          def verify_aircraft_exists?
            @aircraft = ::Aircraft.find_by(id: @aircraft_id)

            if @aircraft.nil?
              add_error(code: :failed, message: 'Could not fetch images. No id Provided.')
              return false
            end

            true
          end
        end
      end
    end
  end
end
