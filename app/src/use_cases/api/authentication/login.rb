module UseCases
  module API
    module Authentication
      class Login
        attr_reader :status, :data

        def initialize(email:, password:)
          @email = email
          @password = password

          @user = nil
          @access_token = nil
        end

        def dispatch(&response)
          if valid_user? && generate_access_token?
            return success(&response)
          end

          error(&response)
        end

        private

        def success(&response)
          http_code = 201
          data = {
            status: 'ok',
            message: 'Authentication was successfull',
            data: {
              access_token: @access_token
            }
          }

          yield http_code, data
        end

        def error(&response)
          http_code = 401
          data = {
            status: 'failed',
            message: 'Authentication failed'
          }

          yield http_code, data
        end

        def valid_user?
          @user = User.find_by(email: @email)

          return true if !@user.nil? && valid_password?

          false
        end

        def valid_password?
          @user.authenticate(@password)
        end

        def generate_access_token?
          authentication_service = ::Services::Authentication.new

          @access_token = authentication_service.generate_jwt(user_id: @user.id)

          true
        end
      end
    end
  end
end
