module Admin
  class UsersAPI < Grape::API
    resource :users do
      get do
        response = ::UseCases::API::Admin::User::Users.new
        response.dispatch do |http_code, data|
          render_response(http_code: http_code, data: data)
        end
      end

      params do
        requires :email, type: String
        requires :password, type: String
      end
      post do
        response = ::UseCases::API::Admin::User::Create.new(email: params[:email], password: params[:password])
        response.dispatch do |http_code, data|
          render_response(http_code: http_code, data: data)
        end
      end
    end
  end
end
