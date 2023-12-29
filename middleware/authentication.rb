module Middleware
  class VerifyToken
    def initialize(app)
      @app = app
    end

    def call(env)
      request = ActionDispatch::Request.new(env)

      if request.path.include?('api/admin') && !verify_token(request)
        return unauthorized_response
      end

      @app.call(env)
    end

    private

    def verify_token(request)
      return false unless request.headers['Authorization'].present?

      access_token = request.headers['Authorization'].sub('Bearer ', '')

      return false unless access_token.present?

      verify_token = ::UseCases::API::Authentication::VerifyAccessToken.new(access_token: access_token)

      verify_token.dispatch do |http_status, data|
        return true if data[:status] == 'ok'
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
