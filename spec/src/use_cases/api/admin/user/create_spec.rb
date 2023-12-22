# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ::UseCases::API::Admin::User::Create do
  let(:email) { '' }
  let(:password) { '' }
  let(:render_response) do
    Proc.new {}
  end

  subject do
    described_class.new(email: email, password: password)
  end

  describe 'the initializer' do
    it 'sets the expected attributes' do
      expect(subject).to have_attributes(
        email: email,
        password: password,
        http_code: 422,
        errors: [],
        messages: []
      )
    end
  end

  describe '#dispatch' do
    context 'when create user fails' do
      let(:email) { '' }
      let(:password) { '' }

      it 'collects errors and returns an error response' do
        subject.dispatch(&render_response)

        expect(subject.http_code).to eq(422)
        expect(subject.errors).to eq(
          [
            { code: :missing, message: 'Email must be provided', field: :email },
            { code: :missing, message: 'Password must be provided', field: :email }
          ]
        )
      end
    end

    context 'when created user succeeds' do
      let(:email) { 'test@example.com' }
      let(:password) { 'test' }

      it 'collects errors and returns an error response' do
        subject.dispatch(&render_response)

        expect(subject.http_code).to eq(201)
        expect(subject.errors).to eq([])
        expect(subject.response_data).to have_attributes(email: email)
      end
    end
  end
end
