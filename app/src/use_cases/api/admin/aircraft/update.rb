# frozen_string_literal: true

module UseCases
  module API
    module Admin
      module Aircraft
        class Update < ::UseCases::API::Base
          attr_reader :errors, :params

          def initialize(params:)
            super()

            @params = params

            @errors = []
          end

          def dispatch(&response)
            if !verify_aircraft_exists?
              @http_code = 422
              add_error(code: :not_found, message: 'Could not find aircraft')

              return error(&response)
            end

            if update_aircraft_details?
              @http_code = 200
              @message = 'Sucessfully updated aircraft'
              @response_data = ::Aircraft.find(@aircraft.id)

              return success(&response)
            end

            @http_code = 422
            add_error(code: :failed, message: 'Could not update aircraft')

            error(&response)
          end

          private

          def existing_images
            return @existing_images if instance_variable_defined?(:@existing_images)

            @existing_images = ::AircraftImage.where(aircraft_id: @aircraft_id)
          end

          def image_urls_to_delete
            return @image_urls_to_delete if instance_variable_defined?(:@image_urls_to_delete)
            return [] if existing_images.blank?

            @image_urls_to_delete = []

            existing_images_urls = existing_images.map(&:url)
            provided_images_urls = @images.map { |image| image['url'] }

            existing_images_urls.each do |existing_image_url|
              @image_urls_to_delete.push(existing_image_url) unless provided_images_urls.include?(existing_image_url)
            end

            @image_urls_to_delete
          end

          def update_aircraft_details?
            @aircraft.model = params[:model] if params[:model]
            @aircraft.description = params[:description] if params[:description]

            @aircraft.save!
          end

          def verify_aircraft_exists?
            @aircraft = ::Aircraft.find_by(id: params[:id])

            return false if @aircraft.nil?

            true
          end
        end
      end
    end
  end
end
