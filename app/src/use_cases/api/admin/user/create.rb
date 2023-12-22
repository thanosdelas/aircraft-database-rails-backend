module UseCases
  module API
    module Admin
      module User
        class Create
          def initialize(email:, password:)
            @email = email
            @password = password
          end

          def dispatch(&response)
            return error(&response) if !verify_email?
            return error(&response) if !verify_password?

            return success(&response) if create_user?

            error(&response)
          end

          private

          def success(&response)
            http_code = 201
            data = {
              status: 'ok',
              message: 'Sucessfully created user',
              data: @user
            }

            yield http_code, data
          end

          def error(&response)
            http_code = 422
            data = {
              status: 'failed',
              message: 'Could not create user'
            }

            yield http_code, data
          end

          def create_user?
            @user = ::User.new
            @user.email = @email
            @user.password = @password

            return true if @user.save

            false
          end

          def verify_email?
            return true if @email.present?

            false
          end

          def verify_password?
            return true if @password.present?

            false
          end
        end
      end
    end
  end
end
