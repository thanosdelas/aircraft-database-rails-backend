# frozen_string_literal: true

module Admin
  class UsersAPI < Grape::API
    resource :users do
      get do
        response = ::UseCases::Admin::User::Users.new
        response.dispatch do |status_code, data|
          render_response(status_code: status_code, data: data)
        end
      end

      params do
        requires :email, type: String
        requires :password, type: String
      end
      post do
        response = ::UseCases::Admin::User::Create.new(email: params[:email], password: params[:password])
        response.dispatch do |status_code, data|
          render_response(status_code: status_code, data: data)
        end
      end
    end
  end
end
