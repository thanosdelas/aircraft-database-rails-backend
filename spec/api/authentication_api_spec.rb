# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AuthenticationAPI do
  include Rack::Test::Methods

  let(:path) { '/api/authentication' }

  describe 'POST /api/authentication/login' do
    let(:params) { {} }
    let(:endpoint) { "#{path}/login" }
    let(:email) { 'test@example.com' }
    let(:password) { 'test' }

    context 'when user authentication is successful' do
      let(:params) do
        {
          email: email,
          password: password
        }
      end

      let(:user_group) do
        UserGroup.new(id: 100, group: 'admin')
      end

      let(:user) do
        User.new(email: params[:email], password: password, group: user_group)
      end

      before do
        user.save!
      end

      it 'successfully creates an access token and responds with 201' do
        post endpoint, params

        expect(last_response.status).to eq(201)

        json = JSON.parse(last_response.body)
        expect(json['status']).to eq('ok')
        expect(json['message']).to eq('Authentication was successfull')
        expect(json['message']).to be_present
      end
    end

    context 'when user authentication fails' do
      context 'because user does not exist' do
        let(:params) do
          {
            email: email,
            password: password
          }
        end

        it 'does not create an access token and responds with 401' do
          post endpoint, params

          expect(last_response.status).to eq(401)
          expect(last_response.body).to eq({ status: 'failed', message: 'Authentication failed' }.to_json)
        end
      end

      context 'because parameters are missing' do
        let(:params) { {} }

        it 'does not create an access token and responds with 401' do
          post endpoint, params

          expect(last_response.status).to eq(400)
          expect(last_response.body).to eq({ error: 'email is missing, password is missing' }.to_json)
        end
      end
    end
  end

  describe 'POST /api/authentication/verify_token' do
    let(:params) { {} }
    let(:endpoint) { "#{path}/verify_token" }

    let(:user) do
      User.new(id: 9999, email: 'test@example.com', password: 'test')
    end

    let(:payload) do
      {
        sub: user.id
      }
    end

    let(:private_key) { OpenSSL::PKey::EC.new(File.read(Rails.root.join('tmp/openssl_keys/jwt-private.pem'))) }
    let(:access_token) do
      JWT.encode payload, private_key, 'ES256'
    end

    context 'when user authentication is successful' do
      let(:params) do
        {
          access_token: access_token
        }
      end

      before do
        user.save
      end

      it 'successfully verifies the access token responds with 201' do
        post endpoint, params

        json = JSON.parse(last_response.body)
        expect(json['status']).to eq('ok')
        expect(json['message']).to eq('Successfully verified token and user')
      end
    end

    context 'when user authentication fails' do
      context 'because access token is invalid' do
        let(:params) do
          {
            access_token: 'INVALID'
          }
        end

        it 'fails to verify the access token and responds with 422' do
          post endpoint, params

          expect(last_response.status).to eq(422)
          expect(last_response.body).to eq({ status: 'failed', message: 'Could not verify provided token' }.to_json)
        end
      end

      context 'because parameters are missing' do
        let(:params) { {} }

        it 'fails to verify the access token and responds with 400' do
          post endpoint, params

          expect(last_response.status).to eq(400)
          expect(last_response.body).to eq({ error: 'access_token is missing' }.to_json)
        end
      end
    end
  end
end
