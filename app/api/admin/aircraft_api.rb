# frozen_string_literal: true

module Admin
  class AircraftAPI < Grape::API
    resource :aircraft do
      get do
        Aircraft.all
      end
    end
  end
end
