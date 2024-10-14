# frozen_string_literal: true

module Admin
  class AircraftAPI < Grape::API
    resource :aircraft do
      params do
        optional :search_term, type: String
      end
      get do
        if params[:search_term].present?
          #
          # TODO: Ensure the following is safe for SQL injection.
          #
          fetch_data = ::Aircraft.where(
            'LOWER(model) LIKE :search_term',
            {
              search_term: "%#{::Aircraft.sanitize_sql_like(params[:search_term])}%"
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

      route_param :id do
        params do
          optional :title, type: String
          optional :description, type: String
        end
        put do
          response = ::UseCases::Admin::Aircraft::Update.new(params: params.symbolize_keys)
          response.dispatch do |http_code, data|
            render_response(http_code: http_code, data: data)
          end
        end

        resource :images do
          get do
            response = ::UseCases::Admin::Aircraft::Images::Fetch.new(aircraft_id: params[:id])
            response.dispatch do |http_code, data|
              render_response(http_code: http_code, data: data)
            end
          end

          params do
            requires :images, type: Array
          end
          put do
            response = ::UseCases::Admin::Aircraft::Images::Update.new(aircraft_id: params['id'], images: params['images'])
            response.dispatch do |http_code, data|
              render_response(http_code: http_code, data: data)
            end
          end
        end
      end
    end
  end
end
