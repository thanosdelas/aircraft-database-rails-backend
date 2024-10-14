# frozen_string_literal: true

module UseCases
  module Admin
    module User
      class Create < ::UseCases::Base
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

          if errors?
            @http_code = 422
            return error(&response)
          end

          if create_user?
            @http_code = 201
            return success(&response)
          end

          @http_code = 422
          error(&response)
        end

        private

        def create_user?
          user = ::User.new
          user.email = @email
          user.password = @password

          unless user.save
            user.errors.each do |error|
              add_error(code: error.type, message: error.message, field: error.attribute)
            end

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
