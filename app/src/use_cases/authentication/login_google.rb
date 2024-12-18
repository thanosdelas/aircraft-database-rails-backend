# frozen_string_literal: true

require 'googleauth'

module UseCases
  module Authentication
    class LoginGoogle < ::UseCases::Base
      attr_reader :status, :googleauth_credential, :payload, :user, :access_token, :data

      def initialize(googleauth_credential:)
        super()

        @googleauth_credential = googleauth_credential
      end

      def dispatch(&response)
        if @googleauth_credential.blank?
          add_error(code: :unauthorized, message: 'Authentication failed')
          return error(&response)
        end

        key_source = Google::Auth::IDTokens::JwkHttpKeySource.new('https://www.googleapis.com/oauth2/v3/certs')
        verifier = Google::Auth::IDTokens::Verifier.new(key_source: key_source)

        begin
          @payload = verifier.verify(@googleauth_credential, aud: '1094984630998-kuso8ldhr1c5321mgdlsthbc22tiio8j.apps.googleusercontent.com')
        rescue Google::Auth::IDTokens::VerificationError => e
          Rails.logger.warn "Token verification failed: #{e.message}"
          add_error(code: :unauthorized, message: 'Authentication failed')
          return error(&response)
        end

        if !verify_user?
          add_error(code: :unauthorized, message: 'Authentication failed')
          return error(&response)
        end

        if generate_access_token?
          @data = {
            access_token: @access_token
          }

          return success(status: :created, &response)
        end

        add_error(code: :unauthorized, message: 'Authentication failed')
        error(&response)
      end

      private

      def verify_user?
        existing_user = User.find_by(email: @payload['email'])

        if existing_user.nil?
          @user = ::User.new(email: @payload['email'], google_sub: @payload['sub'])
          @user.group = ::UserGroup.find_by(group: 'user')

          return true if @user.save

          Rails.logger.warn "Could not save user: #{@user.inspect} from payload: #{@payload.inspect}"
          return false
        end

        if existing_user.google_sub == nil
          existing_user.google_sub = @payload['sub']
          existing_user.password_digest = nil

          if existing_user.save
            @user = existing_user

            return true
          end

          Rails.logger.warn "Could not save existing user: #{@user.inspect} from payload: #{@payload.inspect}"
          return false
        end

        false
      end

      def generate_access_token?
        authentication_service = ::Services::Authentication.new

        @access_token = authentication_service.generate_jwt(user_id: @user.id)

        true
      end
    end
  end
end
