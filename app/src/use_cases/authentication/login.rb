# frozen_string_literal: true

module UseCases
  module Authentication
    class Login < ::UseCases::Base
      attr_reader :status, :data

      def initialize(email:, password:)
        super()

        @email = email
        @password = password

        @user = nil
        @access_token = nil
      end

      def dispatch(&response)
        if valid_user? && generate_access_token?
          @data = {
            access_token: @access_token
          }

          return success(status: :created, &response)
        end

        add_error(code: :unauthorized, message: 'Authentication failed')
        error(&response)
      end

      private

      def valid_user?
        @user = User.find_by(email: @email)

        return false if @user.nil? || !valid_password?

        true
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
