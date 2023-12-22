# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  let(:email) { nil }
  let(:password) { nil }

  subject do
    described_class.new(
      email: email,
      password: password
    )
  end

  context 'when user can be created' do
    let(:email) { 'test@exmple.com' }
    let(:password) { 'test' }

    it 'successfuly creates a user' do
      expect(subject).to be_valid
      expect(subject.save).to eq(true)

      user = User.find_by(email: subject.email)

      expect(user).to have_attributes({
        user_group_id: 300,
        email: email
      })

      expect(user.authenticate(password)).to eq(user)
    end
  end

  context 'when user cannot be created' do
    shared_examples_for 'create user fails' do
      it 'does not create a user' do
        expect(subject).to be_invalid

        expect do
          subject.save
        end.to_not change { User.count }
      end
    end

    context 'because email is not provided' do
      let(:email) { '' }
      let(:password) { 'test' }

      it_behaves_like 'create user fails'
    end

    context 'because password is not provided' do
      let(:email) { 'test@example.com' }
      let(:password) { '' }

      it_behaves_like 'create user fails'
    end
  end
end
