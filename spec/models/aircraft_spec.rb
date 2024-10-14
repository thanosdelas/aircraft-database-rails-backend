# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ::Aircraft, type: :model do
  let(:model) { nil }
  let(:description) { nil }

  subject do
    described_class.new(
      model: model,
      description: description
    )
  end

  context 'when aircraft can be created' do
    let(:model) { 'F-15' }
    let(:description) { 'Aircraft model description' }

    it 'successfuly creates an aircraft' do
      expect(subject).to be_valid
      expect(subject.save).to eq(true)

      aircraft = ::Aircraft.find_by(model: subject.model)

      expect(aircraft).to have_attributes({
        model: model,
        description: description
      })
    end

    context 'when aircraft can be created with images' do
      let(:images) do
        [
          {
            filename: 'test_image_filename.jpg',
            url: 'example.com/test_image_filename.jpg'
          }
        ]
      end

      before(:each) do
        subject.images.new(images)
      end

      it 'successfuly creates an aircraft with images' do
        expect(subject).to be_valid
        expect(subject.save).to eq(true)

        aircraft = ::Aircraft.find_by(model: subject.model)

        expect(aircraft).to have_attributes({
          model: model,
          description: description
        })

        first_image = subject.images.first

        expect(first_image).to have_attributes({
          url: images[0][:url],
          filename: images[0][:filename]
        })
      end
    end
  end

  context 'when aircraft cannot be created' do
    shared_examples_for 'create aircraft fails' do
      it 'does not create an aircraft' do
        expect(subject).to be_invalid

        expect do
          subject.save
        end.to_not change { ::Aircraft.count }
      end
    end

    context 'because model is not provided' do
      let(:model) { nil }

      it_behaves_like 'create aircraft fails'
    end
  end
end
