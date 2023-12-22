# frozen_string_literal: true

module UseCases
  module API
    module Admin
      module User
        class Create < ::UseCases::API::Base
          attr_reader :email, :password

          def initialize(email:, password:)
            super()
            @http_code = 422

            @email = email
            @password = password
          end

          def dispatch(&response)
            ensure_email_is_provided?
            ensure_password_is_provided?
            return error(&response) if errors?

            return success(&response) if create_user?

            error(&response)
          end

          private

          def create_user?
            user = ::User.new
            user.email = @email
            user.password = @password

            unless user.save
              add_error(code: :failed, message: 'Could not create user')
              return false
            end

            @http_code = 201
            @response_data = user
            true
          end

          def ensure_email_is_provided?
            return true if @email.present?

            add_error(code: :missing, message: 'Email must be provided', field: :email)
            false
          end

          def ensure_password_is_provided?
            return true if @password.present?

            add_error(code: :missing, message: 'Password must be provided', field: :email)
            false
          end
        end
      end
    end
  end
end
