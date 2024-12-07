# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ::UseCases::Public::Aircraft::Manufacturer do
  let(:parameters) do
    {}
  end

  let(:render_response) do
    proc {}
  end

  subject do
    described_class.new(parameters: parameters)
  end

  describe 'the initializer' do
    it 'sets the expected attributes' do
      expect(subject).to have_attributes(
        parameters: parameters
      )
    end
  end

  describe '#dispatch' do
    let!(:aircraft_a) do
      FactoryBot.create(:aircraft,
        model: 'Airbus Aircraft A Model',
        first_flight_year: 1956,
        manufacturers: ['Airbus'],
        types: ['Airliner']
      )
    end
    let!(:aircraft_b) do
      FactoryBot.create(:aircraft,
        model: 'Boeing Aircraft B Model',
        first_flight_year: 1970,
        manufacturers: ['Boeing'],
        types: ['Airliner', 'Business Jet']
      )
    end
    let!(:aircraft_c) do
      FactoryBot.create(:aircraft,
        model: 'Airbus Aircraft C Model',
        first_flight_year: 1983,
        manufacturers: ['Airbus'],
        types: ['Airliner']
      )
    end
    let!(:aircraft_bell) do
      FactoryBot.create(:aircraft,
        model: 'Bell Aircraft Model',
        manufacturers: ['Bell Aircraft'],
        first_flight_year: 1976
      )
    end
    let!(:aircraft_helicopter) do
      FactoryBot.create(:aircraft,
        model: 'Bell Hellicopter Model',
        manufacturers: ['Bell Helicopter'],
        first_flight_year: 1976
      )
    end
    let!(:aircraft_beechcraft) do
      FactoryBot.create(:aircraft,
        model: 'Beechcraft Aircraft Model',
        first_flight_year: nil
      )
    end

    context 'when no parameters are provided' do
      let(:parameters) do
        {}
      end

      it 'successfully fetches manufacturers flat' do
        subject.dispatch(&render_response)

        expect(subject.data[:data].length).to eq 19
        expect(subject.data[:data][0]).to have_attributes(manufacturer: 'Airbus', aircraft_count: 2)
        expect(subject.data[:data][1]).to have_attributes(manufacturer: 'Bell Helicopter', aircraft_count: 1)
        expect(subject.data[:data][2]).to have_attributes(manufacturer: 'Bell Aircraft', aircraft_count: 1)
        expect(subject.data[:data][3]).to have_attributes(manufacturer: 'Boeing', aircraft_count: 1)

        current_index = 4
        MANUFACTURERS.each do |manufacturer|
          next if ['Airbus', 'Bell Helicopter', 'Bell Aircraft', 'Boeing'].include?(manufacturer)

          expect(subject.data[:data][current_index]['aircraft_count']).to eq 0

          current_index += 1
        end
      end
    end

    context 'when grouped is provided in parameters' do
      let(:parameters) do
        {
          'grouped' => true
        }
      end

      it 'successfully fetches manufacturer groups' do
        subject.dispatch(&render_response)

        expect(subject.data[:data].length).to eq 3
        expect(subject.data[:data][0]).to have_attributes(manufacturer_group: 'Airbus', manufacturer_count: 3, aircraft_count: 2)
        expect(subject.data[:data][1]).to have_attributes(manufacturer_group: 'Bell', manufacturer_count: 2, aircraft_count: 2)
        expect(subject.data[:data][2]).to have_attributes(manufacturer_group: 'Boeing', manufacturer_count: 3, aircraft_count: 1)
      end
    end
  end
end
