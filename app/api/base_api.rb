# frozen_string_literal: true

class BaseAPI < Grape::API
  include Config

  helpers do
    def render_response(http_code: nil, data:)
      # Set status code in Grape API
      status http_code unless http_code.nil?

      data
    end
  end

  mount UsersAPI
  mount AuthenticationAPI
  mount AircraftAPI

  namespace :admin do
    mount Admin::UsersAPI
  end
end
