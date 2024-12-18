# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::UsersAPI do
  include Rack::Test::Methods

  before do
    authenticate_admin_user
  end

  let(:path) { '/api/admin/users' }

  describe 'GET /api/admin/users' do
    let(:params) { {} }
    let(:endpoint) { path }

    context 'when users can be retrieved' do
      let(:user_1) do
        ::User.new(email: 'test@example.com', password: 'test')
      end

      let(:user_2) do
        ::User.new(email: 'test2@example.com', password: 'test')
      end

      before do
        user_1.save!
        user_2.save!
      end

      it 'successfully retrieves users and responds with 200' do
        get endpoint

        expect(last_response.status).to eq(200)

        data = JSON.parse(last_response.body)
        expect(data.count).to eq(2)
        expect(data.pluck('id')).to eq([user_1.id, user_2.id])
      end
    end
  end

  describe 'POST /api/admin/users' do
    let(:params) { {} }
    let(:endpoint) { path }
    let(:email) { 'test@example.com' }
    let(:password) { 'test' }

    context 'when user can be created' do
      let(:params) do
        {
          email: email,
          password: password
        }
      end

      it 'successfully creates a user and responds with 201' do
        post endpoint, params

        expect(last_response.status).to eq(201)

        data = JSON.parse(last_response.body)
        created_user = ::User.find(data['id'])
        expect(created_user).to have_attributes(
          email: email
        )
      end
    end

    context 'when user cannot be created' do
      context 'because params are missing' do
        let(:params) { {} }

        it 'does not create a user and responds with 400' do
          post endpoint, params

          expect(last_response.status).to eq(400)
          expect(last_response.body).to eq({ error: 'email is missing, password is missing' }.to_json)
        end
      end

      context 'because a user with the provided email exists' do
        let(:params) do
          {
            email: email,
            password: password
          }
        end

        before do
          user = ::User.new(email: email, password: password)
          user.save!
        end

        it 'does not create a user and responds with 422' do
          post endpoint, params

          expect(last_response.status).to eq(422)
          expect(last_response.body).to eq(
            [
              {
                code: :taken,
                message: 'has already been taken',
                field: 'email'
              }
            ].to_json
          )
        end
      end
    end
  end
end
