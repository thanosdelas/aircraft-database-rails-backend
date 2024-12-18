# frozen_string_literal: true

require 'googleauth'

module UseCases
  module Authentication
    class LoginGoogle < ::UseCases::Base
      attr_reader :status, :googleauth_credential, :payload, :user, :access_token, :data

      # To be extracted into config
      GOOGLE_CLIENT_ID = '1094984630998-kuso8ldhr1c5321mgdlsthbc22tiio8j.apps.googleusercontent.com'

      def initialize(googleauth_credential:)
        super()

        @googleauth_credential = googleauth_credential
      end

      def dispatch(&response)
        return error(&response) if !googleauth_credential_provided?
        return error(&response) if !verify_googleauth_credential?
        return error(&response) if !email_verified?
        return error(&response) if !fetch_or_create_user?
        return error(&response) if !generate_access_token?

        @data = {
          access_token: @access_token
        }

        success(status: :created, &response)
      end

      private

      def googleauth_credential_provided?
        return true if @googleauth_credential.present?

        add_error(code: :unauthorized, message: 'Authentication failed')
        false
      end

      def verify_googleauth_credential?
        begin
          @payload = googleauth_verifier.verify(@googleauth_credential, aud: GOOGLE_CLIENT_ID)

          return true
        rescue Google::Auth::IDTokens::VerificationError => e
          Rails.logger.warn "Token verification failed: #{e.message}"
          add_error(code: :unauthorized, message: 'Authentication failed')
        end

        false
      end

      def email_verified?
        return true if @payload['email_verified'] == true

        Rails.logger.warn "Email from payload is not verified: #{@payload.inspect}"
        add_error(code: :unauthorized, message: 'Authentication failed')
        false
      end

      def googleauth_verifier
        return @googleauth_verifier if instance_variable_defined? :@googleauth_verifier

        key_source = Google::Auth::IDTokens::JwkHttpKeySource.new('https://www.googleapis.com/oauth2/v3/certs')

        @googleauth_verifier = Google::Auth::IDTokens::Verifier.new(key_source: key_source)
      end

      def fetch_or_create_user?
        @user = User.find_by(email: @payload['email'])

        return create_user? if @user.nil?

        return true if @user.google_sub == @payload['sub']

        set_existing_user_sub_and_remove_password?
      end

      def create_user?
        @user = ::User.new(email: @payload['email'], google_sub: @payload['sub'])
        @user.group = ::UserGroup.find_by(group: 'user')

        return true if @user.save

        Rails.logger.warn "Could not create user: #{@user.inspect} from payload: #{@payload.inspect}"
        add_error(code: :unauthorized, message: 'Authentication failed')
        false
      end

      def set_existing_user_sub_and_remove_password?
        @user.google_sub = @payload['sub']
        @user.password_digest = nil

        if @user.save
          Rails.logger.info "Successfully updated sub and removed password for existing user: #{@user.inspect} from payload: #{@payload.inspect}"
          return true
        end

        Rails.logger.warn "Could not save existing user: #{@user.inspect} from payload: #{@payload.inspect}"
        add_error(code: :unauthorized, message: 'Authentication failed')
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
