# frozen_string_literal: true

module UseCases
  module Admin
    module User
      class Create < ::UseCases::Base
        attr_reader :email, :password

        def initialize(email:, password:)
          super()

          @email = email
          @password = password
        end

        def dispatch(&response)
          ensure_email_is_provided?
          ensure_password_is_provided?

          return error(&response) if errors? || !create_user?

          success(status: :created, &response)
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

          @data = user
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
