module UseCases
  module API
    module Authentication
      class VerifyAccessToken
        attr_reader :status, :data

        def initialize(access_token:)
          @access_token = access_token
        end

        def dispatch(&response)
          return success(&response) if verify_access_token?

          error(&response)
        end

        private

        def success
          http_code = 201
          data = {
            status: 'ok',
            message: 'Successfully verified token and user'
          }

          yield http_code, data
        end

        def error
          http_code = 422
          data = {
            status: 'failed',
            message: 'Could not verify provided token'
          }

          yield http_code, data
        end

        def verify_access_token?
          authentication_service = ::Services::Authentication.new

          payload = authentication_service.verify_access_token(@access_token)

          return false if payload.nil?
          return false if user_exists?(payload[:sub])

          true
        rescue JWT::DecodeError, JWT::VerificationError
          # You may log these errors
          false
        end

        def user_exists?(user_id)
          user = User.find_by(id: user_id)

          return true if !user.nil?

          false
        end
      end
    end
  end
end
