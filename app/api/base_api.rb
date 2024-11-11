# frozen_string_literal: true

class BaseAPI < Grape::API
  include Config

  USE_CASE_STATUS_TO_HTTP_CODES = {
    ok: 200,
    success: 200,
    created: 201,
    updated: 200,
    deleted: 204,
    queued: 202,
    bad_request: 400,
    unauthorized: 401,
    forbidden: 403,
    not_found: 404,
    conflict: 409,
    taken: 422,
    failed: 422,
    missing: 422,
    unprocessable_content: 422
  }.freeze

  helpers do
    def render_response(data:, status_code: nil)
      # Precondition Failed
      status 412

      raise "Unsupported status code provided: #{status_code}" if USE_CASE_STATUS_TO_HTTP_CODES[status_code].nil?

      # Set http tatus code in Grape API
      status USE_CASE_STATUS_TO_HTTP_CODES[status_code]

      data
    end
  end

  mount UsersAPI
  mount AuthenticationAPI
  mount AircraftAPI
  mount AircraftTypesAPI
  mount AircraftManufacturersAPI

  namespace :admin do
    mount Admin::UsersAPI
    mount Admin::AircraftAPI
  end
end
