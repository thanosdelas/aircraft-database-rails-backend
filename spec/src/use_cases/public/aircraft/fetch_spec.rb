# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ::UseCases::Public::Aircraft::Fetch do
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
        manufacturers: ['Airbus', 'Antonov'],
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
    let!(:aircraft_c) { FactoryBot.create(:aircraft, model: 'Antonov Aircraft C Model', first_flight_year: 1985) }
    let!(:aircraft_d) { FactoryBot.create(:aircraft, model: 'Beechcraft Aircraft D Model', first_flight_year: nil) }
    let!(:aircraft_e) do
      FactoryBot.create(:aircraft,
        model: 'Beechcraft Aircraft E Model',
        wikipedia_info_collected: false
      )
    end

    context 'when no parameters are provided' do
      let(:parameters) do
        {}
      end

      it 'successfully fetches aircraft' do
        subject.dispatch(&render_response)

        expect(subject.data[:data].length).to eq 4
        expect(subject.data[:data][0]).to have_attributes(model: 'Airbus Aircraft A Model')
        expect(subject.data[:data][1]).to have_attributes(model: 'Boeing Aircraft B Model')
        expect(subject.data[:data][2]).to have_attributes(model: 'Antonov Aircraft C Model')
        expect(subject.data[:data][3]).to have_attributes(model: 'Beechcraft Aircraft D Model')
        expect(subject.data[:metadata]).to eq({ first_flight_year_bounds: { year_min: 1956, year_max: 1985 } })
      end
    end

    context 'when manufacturer is provided in parameters' do
      let(:parameters) do
        {
          'manufacturer' => 'Airbus'
        }
      end

      it 'successfully fetches aircraft' do
        subject.dispatch(&render_response)

        expect(subject.data[:data].length).to eq 1
        expect(subject.data[:data][0]).to have_attributes(model: 'Airbus Aircraft A Model')
        expect(subject.data[:metadata]).to eq({ first_flight_year_bounds: { year_min: 1956, year_max: 1956 } })
      end
    end

    context 'when aircraft_type is provided in parameters' do
      let(:parameters) do
        {
          'aircraft_type' => 'Airliner'
        }
      end

      it 'successfully fetches aircraft' do
        subject.dispatch(&render_response)

        expect(subject.data[:data].length).to eq 2
        expect(subject.data[:data][1]).to have_attributes(model: 'Airbus Aircraft A Model')
        expect(subject.data[:data][0]).to have_attributes(model: 'Boeing Aircraft B Model')
        expect(subject.data[:metadata]).to eq({ first_flight_year_bounds: { year_min: 1956, year_max: 1970 } })
      end
    end
  end
end
