# frozen_string_literal: true

module UseCases
  module API
    module Admin
      module Aircraft
        module Images
          class Update
            attr_reader :errors

            def initialize(aircraft_id:, images:)
              @aircraft_id = aircraft_id
              @images = images

              @errors = []
            end

            def dispatch(&response)
              return error(&response) if !verify_aircraft_id? ||
                                         !verify_images? ||
                                         !verify_aircraft_exists?

              return success(&response) if save_images?

              error(&response)
            end

            private

            def success
              http_code = 200
              data = {
                status: 'ok',
                message: 'Sucessfully updated images',
                data: ::AircraftImage.where(aircraft_id: @aircraft_id)
              }

              yield http_code, data
            end

            def error
              http_code = 422
              data = {
                status: 'failed',
                message: 'Could not update images'
              }

              yield http_code, data
            end

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

            # TODO: - Collect and return errors
            #       - Avoid n+1 queries
            def save_images? # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
              ::AircraftImage.transaction do
                image_urls_to_delete.each do |image_url|
                  ::AircraftImage.where(url: image_url).destroy_all
                end

                @images.each do |image|
                  next if AircraftImage.find_by(url: image['url'])

                  create_image = AircraftImage.new(
                    aircraft_id: @aircraft_id,
                    url: image['url'],
                    filename: image['filename']
                  )

                  create_image.description = image['description'] if image['description'].present?
                  create_image.save!
                end
              end

              true
            rescue ActiveRecord::RecordInvalid => error
              @errors.push({
                code: 'error',
                message: error.message
              })

              return false
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

            def verify_images?
              return true if @images.present?
              return true if @images.is_a?(Array)

              false
            end
          end
        end
      end
    end
  end
end
