# frozen_string_literal: true

FactoryBot.define do
  factory :manufacturer do
    manufacturer { "" }
  end
end

FactoryBot.define do
  factory :type do
    aircraft_type { "" }
  end
end

FactoryBot.define do
  factory :aircraft_manufacturer do
    aircraft { nil }
    manufacturer { nil }
  end
end

FactoryBot.define do
  factory :aircraft_type do
    aircraft { nil }
    aircraft_type { nil }
  end
end

FactoryBot.define do
  factory :aircraft do
    model { nil }
    first_flight_year { nil }
    wikipedia_info_collected { true }

    after(:create) do |aircraft, evaluator|
      if evaluator.types.present?
        aircraft.types = Type.where(aircraft_type: evaluator.types)
      end

      if evaluator.manufacturers.present?
        aircraft.manufacturers = Manufacturer.where(manufacturer: evaluator.manufacturers)
      end
    end

    transient do
      types { [] }
      manufacturers { [] }
    end
  end
end
