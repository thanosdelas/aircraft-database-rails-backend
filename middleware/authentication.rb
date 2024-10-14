# frozen_string_literal: true

module Middleware
  class VerifyToken
    def initialize(app)
      @app = app
    end

    def call(env)
      request = ActionDispatch::Request.new(env)

      return unauthorized_response if request.path.include?('api/admin') && !verify_token(request)

      @app.call(env)
    end

    private

    def verify_token(request)
      return false if request.headers['Authorization'].blank?

      access_token = request.headers['Authorization'].sub('Bearer ', '')

      return false if access_token.blank?

      verify_token = ::UseCases::Authentication::VerifyAccessToken.new(access_token: access_token)

      verify_token.dispatch do |_http_status, data|
        return true if data[:status] == 'success'
      end

      false
    end

    def unauthorized_response
      response = { message: 'Unauthorized' }.to_json

      headers = {}
      headers['Content-Length'] = response.bytesize.to_s

      [401, headers, [response]]
    end
  end
end
