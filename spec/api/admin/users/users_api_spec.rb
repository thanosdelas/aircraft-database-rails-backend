require 'rails_helper'

describe Admin::UsersAPI do
  include Rack::Test::Methods

  let(:path) { '/api/admin/users' }

  describe 'GET /api/admin/users' do
    let(:params) { {} }
    let(:endpoint) { "#{path}" }

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

        json = JSON.parse(last_response.body)

        expect(json['data']['users'].count).to eq(2)
        expect(json['data']['users'].pluck('id')).to eq([user_1.id, user_2.id])
      end
    end
  end

  describe 'POST /api/admin/users' do
    let(:params) { {} }
    let(:endpoint) { "#{path}" }
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

        json = JSON.parse(last_response.body)
        created_user = ::User.find(json['data']['id'])
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
          expect(last_response.body).to eq({
            status: 'failed',
            message: 'Could not create user',
          }.to_json)
        end
      end
    end
  end
end