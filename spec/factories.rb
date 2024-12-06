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
    aircraft { "" }
    manufacturer { "" }
  end
end

FactoryBot.define do
  factory :aircraft do
    model { nil }
    first_flight_year { nil }
    wikipedia_info_collected { true }

    after(:create) do |aircraft, evaluator|
      if evaluator.manufacturers.present?
        aircraft.manufacturers = Manufacturer.where(manufacturer: evaluator.manufacturers)
      end
    end

    transient do
      manufacturers { [] }
    end
  end
end
