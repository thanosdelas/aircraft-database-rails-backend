# frozen_string_literal: true

module UseCases
  module Authentication
    class VerifyAccessToken < ::UseCases::Base
      attr_reader :status, :data

      def initialize(access_token:)
        super()

        @access_token = access_token
      end

      def dispatch(&response)
        return success(status: :created, &response) if verify_access_token?

        add_error(code: :unauthorized, message: 'Could not verify token')
        error(&response)
      end

      private

      def verify_access_token?
        authentication_service = ::Services::Authentication.new

        payload = authentication_service.verify_access_token(@access_token)

        return false if payload.nil?
        return false if user_exists?(payload[:sub])

        true
      rescue JWT::DecodeError, JWT::VerificationError
        # We may log these errors
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
