# frozen_string_literal: true

module UseCases
  module Admin
    module Aircraft
      class Update < ::UseCases::Base
        attr_reader :params

        def initialize(params:)
          super()

          @params = params
        end

        def dispatch(&response)
          return error(&response) if !verify_aircraft_exists?

          return error(&response) if !update_aircraft_details?

          @data = ::Aircraft.find(@aircraft.id)
          success(&response)
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

          if !@aircraft.save!
            add_error(code: :failed, message: 'Could not update aircraft')

            return false
          end

          true
        end

        def verify_aircraft_exists?
          @aircraft = ::Aircraft.find_by(id: params[:id])

          if @aircraft.nil?
            add_error(code: :not_found, message: 'Could not find aircraft')

            return false
          end

          true
        end
      end
    end
  end
end
