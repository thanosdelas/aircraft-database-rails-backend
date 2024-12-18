# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ::UseCases::Admin::User::Create do
  let(:email) { '' }
  let(:password) { '' }
  let(:render_response) do
    proc {}
  end

  subject do
    described_class.new(email: email, password: password)
  end

  describe 'the initializer' do
    it 'sets the expected attributes' do
      expect(subject).to have_attributes(
        email: email,
        password: password,
        errors: []
      )
    end
  end

  describe '#dispatch' do
    context 'when create user fails' do
      let(:email) { '' }
      let(:password) { '' }

      it 'collects errors and returns an error response' do
        subject.dispatch(&render_response)

        expect(subject.errors).to eq(
          [
            { code: :missing, message: 'Email must be provided', field: :email },
            { code: :missing, message: 'Password must be provided', field: :email }
          ]
        )
      end

      context 'because group is missing' do
        let(:email) { 'test@example.com' }
        let(:password) { 'test' }

        before do
          ::UserGroup.find_by(group: 'user').delete
        end

        it 'returns a successful response with no errors' do
          subject.dispatch(&render_response)

          expect(subject.errors).to eq([
            { code: :blank, message: 'must exist', field: :group }
          ])
        end
      end
    end
  end
end
