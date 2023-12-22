# frozen_string_literal: true

module Config
  extend ActiveSupport::Concern

  included do
    prefix 'api'
    default_format :json
    content_type :json, 'application/json'
  end
end
