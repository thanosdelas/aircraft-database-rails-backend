# frozen_string_literal: true

module UseCases
  module Admin
    module Aircraft
      module Images
        class Update < ::UseCases::Base
          def initialize(aircraft_id:, images:)
            super()

            @aircraft_id = aircraft_id
            @images = images
          end

          def dispatch(&response)
            return error(&response) if !verify_aircraft_id? ||
                                       !verify_images? ||
                                       !verify_aircraft_exists? ||
                                       !save_images?

            @data = ::AircraftImage.where(aircraft_id: @aircraft_id)
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
            add_error(code: :failed, message: error.message)

            false
          end

          def verify_aircraft_id?
            if @aircraft_id.blank?
              add_error(code: :failed, message: 'Could not update images')

              return false
            end

            true
          end

          def verify_aircraft_exists?
            @aircraft = ::Aircraft.find_by(id: @aircraft_id)

            if @aircraft.nil?
              add_error(code: :failed, message: 'Could not update images')

              return false
            end

            true
          end

          def verify_images?
            if @images.blank? || !@images.is_a?(Array)
              add_error(code: :failed, message: 'Could not update images')

              return false
            end

            true
          end
        end
      end
    end
  end
end
