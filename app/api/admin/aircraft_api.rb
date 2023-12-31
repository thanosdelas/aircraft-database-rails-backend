# frozen_string_literal: true

module Admin
  class AircraftAPI < Grape::API
    resource :aircraft do
      params do
        optional :search_term, type: String
      end
      get do
        puts params[:search_term].inspect

        if params[:search_term].present?
          #
          # TODO: Ensure the following is safe for SQL injection.
          #
          fetch_data = ::Aircraft.where(
            "LOWER(model) LIKE :search_term",
            {
              search_term: "%#{ ::Aircraft.sanitize_sql_like(params[:search_term]) }%"
            }
          )
        else
          fetch_data = ::Aircraft.all
        end

        http_code = 200
        data = {
          status: 'ok',
          message: 'Sucessfully fetched images',
          data: fetch_data
        }

        render_response(http_code: http_code, data: data)
      end

      resource :images do
        params do
          requires :aircraft_id, type: String
        end
        get do
          response = ::UseCases::API::Admin::Aircraft::Images::Fetch.new(aircraft_id: params[:aircraft_id])

          response.dispatch do |http_code, data|
            render_response(http_code: http_code, data: data)
          end
        end

        params do
          requires :aircraft_id, type: String
          requires :images, type: Array
        end
        put do
          response = ::UseCases::API::Admin::Aircraft::Images::Update.new(
            aircraft_id: params[:aircraft_id],
            images: params[:images]
          )

          response.dispatch do |http_code, data|
            render_response(http_code: http_code, data: data)
          end
        end
      end
    end
  end
end
