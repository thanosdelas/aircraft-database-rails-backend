# frozen_string_literal: true

require 'rails_helper'
require 'webmock/rspec'

RSpec.describe ::UseCases::Authentication::LoginGoogle do
  let(:googleauth_credential) { '' }

  let(:render_response) do
    proc {}
  end

  subject do
    described_class.new(googleauth_credential: googleauth_credential)
  end

  describe 'the initializer' do
    it 'sets the expected attributes' do
      expect(subject).to have_attributes(
        googleauth_credential: googleauth_credential
      )
    end
  end

  describe '#dispatch' do
    context 'when google login fails' do
      context 'when no googleauth is provided' do
        let(:googleauth_credential) { '' }

        it 'fails to authenticate and responds with errors' do
          subject.dispatch(&render_response)

          expect(subject.errors).to eq [{ code: :unauthorized, message: 'Authentication failed' }]
        end
      end

      context 'when no key source found' do
        let(:googleauth_credential) { '123456789' }
        let!(:google_jwk_oauth_v3_request) do
          stub_request(:get, 'https://www.googleapis.com/oauth2/v3/certs')
            .to_return(
              {
                status: 200,
                body: '{}',
                headers: { content_type: 'application/json' }
              }
            )
        end

        it 'fails to authenticate and raises error' do
          expect do
            subject.dispatch(&render_response)
          end.to raise_error Google::Auth::IDTokens::KeySourceError
        end
      end

      context 'when Google::Auth::IDTokens::VerificationError' do
        let(:googleauth_credential) { '123456789' }
        let(:google_jwk_oauth_v3_response) do
          {
            keys: [
              {
                kty: 'RSA',
                e: 'AQAB',
                n: 'p4FEhRwWtJxTdllpjXeSQzAdDqQQhmByHHUkjjERSOAaqyqz8eIWOOulAar3oGpa4HyIJoA5bx7J3pmerfQsX1MaTF1vyWAVnDsgoUS6jfGnrxerhWrC8GotcBewM4wuI-1uT1Edng8Req6bP1WxW1fUATd1TabNLDW-wy4OVvL45b82g4wHGMWxreILdC8xdlyxcsPvh5gr5CHgxPAh-f3X6l_IJePJs6m_auYRmW8Cban84KaLS0NzZuydxvRPA4jozIGl1E08-szCJnjjvn-nVkLYHuJf8DYCp9HWT0_2kSsumqs0PFFnEdngFsPzpD7EuGGs0BTARJFMtmCrWQ',
                alg: 'RS256',
                kid: '564feacec3ebdfaa7311b9d8e73c42818f291264',
                use: 'sig'
              },
              {
                e: 'AQAB',
                use: 'sig',
                kty: 'RSA',
                n: 'qL80q4yfbwG9vt_x1CBgv51oMOlOV1nEIWxcPrEJ_hd1Zf6Tv-gGNQUTzdRqhWUB7VZbIe7IGQ8XrqqZhJkSSRutWYgcB7CZAQPsz2uUzJfULIrqU5-3s1V6TsAvDd0XAhTrxsukBZhvSUcObns6oyr2tvCeYkdlbZ7HHgUjGLt2JduwfVfSDVOXm9iev36W0cDv2RS45H7c4rBaXnvhMQ6BOMA8xeSI05SCwYGpZp5prgQE_xyBPB_EHBOheDOgdtOEvceGg4zMSRni7a5S0ux5EmTOUVxMXOdOzlLmBHMNPYpAjjgYz4afhNuwAlp0BhEhSWwINOGh22U8iU1pIQ',
                kid: '31b8fccb2e52253b133138acf0e56632f09957ee',
                alg: 'RS256'
              }
            ]
          }
        end

        let!(:google_jwk_oauth_v3_request) do
          stub_request(:get, 'https://www.googleapis.com/oauth2/v3/certs')
            .to_return(
              {
                status: 200,
                body: google_jwk_oauth_v3_response.to_json,
                headers: { content_type: 'application/json' }
              }
            )
        end

        it 'fails to authenticate and responds with errors' do
          subject.dispatch(&render_response)

          expect(subject.errors).to eq [{ code: :unauthorized, message: 'Authentication failed' }]
        end
      end
    end

    context 'when provided googleauth credential is valid' do
      context 'when user does not exist' do
        let(:googleauth_credential) { '123456789' }
        let(:google_jwk_oauth_v3_response) do
          {
            keys: [
              {
                kty: 'RSA',
                e: 'AQAB',
                n: 'p4FEhRwWtJxTdllpjXeSQzAdDqQQhmByHHUkjjERSOAaqyqz8eIWOOulAar3oGpa4HyIJoA5bx7J3pmerfQsX1MaTF1vyWAVnDsgoUS6jfGnrxerhWrC8GotcBewM4wuI-1uT1Edng8Req6bP1WxW1fUATd1TabNLDW-wy4OVvL45b82g4wHGMWxreILdC8xdlyxcsPvh5gr5CHgxPAh-f3X6l_IJePJs6m_auYRmW8Cban84KaLS0NzZuydxvRPA4jozIGl1E08-szCJnjjvn-nVkLYHuJf8DYCp9HWT0_2kSsumqs0PFFnEdngFsPzpD7EuGGs0BTARJFMtmCrWQ',
                alg: 'RS256',
                kid: '564feacec3ebdfaa7311b9d8e73c42818f291264',
                use: 'sig'
              },
              {
                e: 'AQAB',
                use: 'sig',
                kty: 'RSA',
                n: 'qL80q4yfbwG9vt_x1CBgv51oMOlOV1nEIWxcPrEJ_hd1Zf6Tv-gGNQUTzdRqhWUB7VZbIe7IGQ8XrqqZhJkSSRutWYgcB7CZAQPsz2uUzJfULIrqU5-3s1V6TsAvDd0XAhTrxsukBZhvSUcObns6oyr2tvCeYkdlbZ7HHgUjGLt2JduwfVfSDVOXm9iev36W0cDv2RS45H7c4rBaXnvhMQ6BOMA8xeSI05SCwYGpZp5prgQE_xyBPB_EHBOheDOgdtOEvceGg4zMSRni7a5S0ux5EmTOUVxMXOdOzlLmBHMNPYpAjjgYz4afhNuwAlp0BhEhSWwINOGh22U8iU1pIQ',
                kid: '31b8fccb2e52253b133138acf0e56632f09957ee',
                alg: 'RS256'
              }
            ]
          }
        end

        let!(:google_jwk_oauth_v3_request) do
          stub_request(:get, 'https://www.googleapis.com/oauth2/v3/certs')
            .to_return(
              {
                status: 200,
                body: google_jwk_oauth_v3_response.to_json,
                headers: { content_type: 'application/json' }
              }
            )
        end

        let(:googleauth_verified_payload) do
          {
            iss: 'https://accounts.google.com',
            nbf: '123456789',
            aud: 'google_app_client_id',
            sub: '11111111111111111111',
            email: 'email@example.com',
            email_verified: true,
            name: 'Firstname Lastname',
            iat: '123456789',
            exp: '123456789'
          }
        end

        before do
          allow_any_instance_of(Google::Auth::IDTokens::Verifier).to receive(:verify).and_return(googleauth_verified_payload.stringify_keys!)
        end

        it 'fails to authenticate and responds with errors' do
          expect do
            subject.dispatch(&render_response)
          end.to change { ::User.count }.by 1

          expect(subject.errors).to eq []
          expect(subject.access_token).to_not eq nil
          expect(subject.user).to have_attributes(
            email: 'email@example.com',
            password_digest: nil,
            google_sub: '11111111111111111111'
          )
          expect(subject.user.group.group).to eq 'user'
        end
      end

      context 'when user exists' do
        let(:googleauth_credential) { '123456789' }
        let(:google_jwk_oauth_v3_response) do
          {
            keys: [
              {
                kty: 'RSA',
                e: 'AQAB',
                n: 'p4FEhRwWtJxTdllpjXeSQzAdDqQQhmByHHUkjjERSOAaqyqz8eIWOOulAar3oGpa4HyIJoA5bx7J3pmerfQsX1MaTF1vyWAVnDsgoUS6jfGnrxerhWrC8GotcBewM4wuI-1uT1Edng8Req6bP1WxW1fUATd1TabNLDW-wy4OVvL45b82g4wHGMWxreILdC8xdlyxcsPvh5gr5CHgxPAh-f3X6l_IJePJs6m_auYRmW8Cban84KaLS0NzZuydxvRPA4jozIGl1E08-szCJnjjvn-nVkLYHuJf8DYCp9HWT0_2kSsumqs0PFFnEdngFsPzpD7EuGGs0BTARJFMtmCrWQ',
                alg: 'RS256',
                kid: '564feacec3ebdfaa7311b9d8e73c42818f291264',
                use: 'sig'
              },
              {
                e: 'AQAB',
                use: 'sig',
                kty: 'RSA',
                n: 'qL80q4yfbwG9vt_x1CBgv51oMOlOV1nEIWxcPrEJ_hd1Zf6Tv-gGNQUTzdRqhWUB7VZbIe7IGQ8XrqqZhJkSSRutWYgcB7CZAQPsz2uUzJfULIrqU5-3s1V6TsAvDd0XAhTrxsukBZhvSUcObns6oyr2tvCeYkdlbZ7HHgUjGLt2JduwfVfSDVOXm9iev36W0cDv2RS45H7c4rBaXnvhMQ6BOMA8xeSI05SCwYGpZp5prgQE_xyBPB_EHBOheDOgdtOEvceGg4zMSRni7a5S0ux5EmTOUVxMXOdOzlLmBHMNPYpAjjgYz4afhNuwAlp0BhEhSWwINOGh22U8iU1pIQ',
                kid: '31b8fccb2e52253b133138acf0e56632f09957ee',
                alg: 'RS256'
              }
            ]
          }
        end

        let!(:google_jwk_oauth_v3_request) do
          stub_request(:get, 'https://www.googleapis.com/oauth2/v3/certs')
            .to_return(
              {
                status: 200,
                body: google_jwk_oauth_v3_response.to_json,
                headers: { content_type: 'application/json' }
              }
            )
        end

        let(:googleauth_verified_payload) do
          {
            iss: 'https://accounts.google.com',
            nbf: '123456789',
            aud: 'google_app_client_id',
            sub: '11111111111111111111',
            email: 'email@example.com',
            email_verified: true,
            name: 'Firstname Lastname',
            iat: '123456789',
            exp: '123456789'
          }
        end

        let!(:user) do
          FactoryBot.create(:user, email: 'email@example.com', password: '123456789')
        end

        before do
          allow_any_instance_of(Google::Auth::IDTokens::Verifier).to receive(:verify).and_return(googleauth_verified_payload.stringify_keys!)
        end

        it 'fails to authenticate and responds with errors' do
          expect do
            subject.dispatch(&render_response)
          end.to_not change { ::User.count }

          expect(subject.errors).to eq []
          expect(subject.access_token).to_not eq nil
          expect(subject.user).to have_attributes(
            email: 'email@example.com',
            password_digest: nil,
            google_sub: '11111111111111111111'
          )
          expect(subject.user.group.group).to eq 'user'
        end
      end

      context 'when email in payload is not verified' do
        let(:googleauth_credential) { '123456789' }
        let(:google_jwk_oauth_v3_response) do
          {
            keys: [
              {
                kty: 'RSA',
                e: 'AQAB',
                n: 'p4FEhRwWtJxTdllpjXeSQzAdDqQQhmByHHUkjjERSOAaqyqz8eIWOOulAar3oGpa4HyIJoA5bx7J3pmerfQsX1MaTF1vyWAVnDsgoUS6jfGnrxerhWrC8GotcBewM4wuI-1uT1Edng8Req6bP1WxW1fUATd1TabNLDW-wy4OVvL45b82g4wHGMWxreILdC8xdlyxcsPvh5gr5CHgxPAh-f3X6l_IJePJs6m_auYRmW8Cban84KaLS0NzZuydxvRPA4jozIGl1E08-szCJnjjvn-nVkLYHuJf8DYCp9HWT0_2kSsumqs0PFFnEdngFsPzpD7EuGGs0BTARJFMtmCrWQ',
                alg: 'RS256',
                kid: '564feacec3ebdfaa7311b9d8e73c42818f291264',
                use: 'sig'
              },
              {
                e: 'AQAB',
                use: 'sig',
                kty: 'RSA',
                n: 'qL80q4yfbwG9vt_x1CBgv51oMOlOV1nEIWxcPrEJ_hd1Zf6Tv-gGNQUTzdRqhWUB7VZbIe7IGQ8XrqqZhJkSSRutWYgcB7CZAQPsz2uUzJfULIrqU5-3s1V6TsAvDd0XAhTrxsukBZhvSUcObns6oyr2tvCeYkdlbZ7HHgUjGLt2JduwfVfSDVOXm9iev36W0cDv2RS45H7c4rBaXnvhMQ6BOMA8xeSI05SCwYGpZp5prgQE_xyBPB_EHBOheDOgdtOEvceGg4zMSRni7a5S0ux5EmTOUVxMXOdOzlLmBHMNPYpAjjgYz4afhNuwAlp0BhEhSWwINOGh22U8iU1pIQ',
                kid: '31b8fccb2e52253b133138acf0e56632f09957ee',
                alg: 'RS256'
              }
            ]
          }
        end

        let!(:google_jwk_oauth_v3_request) do
          stub_request(:get, 'https://www.googleapis.com/oauth2/v3/certs')
            .to_return(
              {
                status: 200,
                body: google_jwk_oauth_v3_response.to_json,
                headers: { content_type: 'application/json' }
              }
            )
        end

        let(:googleauth_verified_payload) do
          {
            iss: 'https://accounts.google.com',
            nbf: '123456789',
            aud: 'google_app_client_id',
            sub: '11111111111111111111',
            email: 'email@example.com',
            email_verified: false,
            name: 'Firstname Lastname',
            iat: '123456789',
            exp: '123456789'
          }
        end

        let!(:user) do
          FactoryBot.create(:user, email: 'email@example.com', password: '123456789')
        end

        before do
          allow_any_instance_of(Google::Auth::IDTokens::Verifier).to receive(:verify).and_return(googleauth_verified_payload.stringify_keys!)
        end

        it 'fails to authenticate and responds with errors' do
          expect do
            subject.dispatch(&render_response)
          end.to_not change { ::User.count }

          expect(subject.errors).to eq [{ code: :unauthorized, message: 'Authentication failed' }]
          expect(subject.access_token).to eq nil
        end
      end
    end
  end
end
