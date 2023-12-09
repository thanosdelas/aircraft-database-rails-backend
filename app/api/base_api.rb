# frozen_string_literal: true

class BaseAPI < Grape::API
  include Config

  mount UsersAPI
end
