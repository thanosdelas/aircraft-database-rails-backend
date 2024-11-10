# frozen_string_literal: true

module Admin
  class AircraftAPI < Grape::API
    resource :aircraft do
      params do
        optional :search_term, type: String
      end
      get do
        if params[:search_term].present?
          fetch_data = ::Aircraft.where(
            'LOWER(model) LIKE :search_term',
            {
              search_term: "%#{::Aircraft.sanitize_sql_like(params[:search_term])}%"
            }
          )
        else
          fetch_data = ::Aircraft.all
        end

        status_code = :success
        data = {
          data: fetch_data
        }

        render_response(status_code: status_code, data: data)
      end

      route_param :id do
        get do
          aircraft = JSON.parse(
            ::Aircraft.includes(:types)
                      .includes(:images)
                      .find_by(id: params[:id])
                      .to_json(include: [:types, :images])
          )

          render_response(status_code: :ok, data: aircraft)
        end

        params do
          optional :title, type: String
          optional :description, type: String
        end
        put do
          response = ::UseCases::Admin::Aircraft::Update.new(params: params.symbolize_keys)
          response.dispatch do |status_code, data|
            render_response(status_code: status_code, data: data)
          end
        end

        resource :images do
          get do
            response = ::UseCases::Admin::Aircraft::Images::Fetch.new(aircraft_id: params[:id])
            response.dispatch do |status_code, data|
              render_response(status_code: status_code, data: data)
            end
          end

          params do
            requires :images, type: Array
          end
          put do
            response = ::UseCases::Admin::Aircraft::Images::Update.new(aircraft_id: params['id'], images: params['images'])
            response.dispatch do |status_code, data|
              render_response(status_code: status_code, data: data)
            end
          end
        end
      end
    end
  end
end
