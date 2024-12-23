# frozen_string_literal: true

class AuthenticationAPI < BaseAPI
  resource :authentication do
    params do
      requires :email, type: String
      requires :password, type: String
    end
    post 'login' do
      response = ::UseCases::Authentication::Login.new(email: params[:email], password: params[:password])
      response.dispatch do |status_code, data|
        render_response(status_code: status_code, data: data)
      end
    end

    post 'login/google' do
      response = ::UseCases::Authentication::LoginGoogle.new(googleauth_credential: params[:googleauth_credential])
      response.dispatch do |status_code, data|
        render_response(status_code: status_code, data: data)
      end
    end

    params do
      requires :access_token, type: String
    end
    post 'verify_token' do
      response = ::UseCases::Authentication::VerifyAccessToken.new(access_token: params[:access_token])
      response.dispatch do |status_code, data|
        render_response(status_code: status_code, data: data)
      end
    end
  end
end
