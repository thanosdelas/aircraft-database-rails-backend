# frozen_string_literal: true

class UsersAPI < Grape::API
  resource :users do
    get do
      User.all
    end
  end
end
