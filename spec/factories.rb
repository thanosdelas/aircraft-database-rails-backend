# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { nil }
    password { nil }
  end
end

FactoryBot.define do
  factory :manufacturer_group do
    manufacturer_group { nil }
  end
end

FactoryBot.define do
  factory :manufacturer do
    manufacturer { nil }
    manufacturer_group { nil }

    after(:create) do |manufacturer, evaluator|
      if evaluator.manufacturer_group_string.present?
        manufacturer.manufacturer_group = ::ManufacturerGroup.where(manufacturer_group: evaluator.manufacturer_group_string).first
        manufacturer.save!
      end
    end

    transient do
      manufacturer_group_string { nil }
    end
  end
end

FactoryBot.define do
  factory :type do
    aircraft_type { nil }
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
      aircraft.types = Type.where(aircraft_type: evaluator.types) if evaluator.types.present?
      aircraft.manufacturers = Manufacturer.where(manufacturer: evaluator.manufacturers) if evaluator.manufacturers.present?

      if evaluator.images.present?
        aircraft_images = []

        evaluator.images.each do |image|
          aircraft_images.push(::AircraftImage.new(image))
        end

        aircraft.images = aircraft_images
        aircraft.save!
      end
    end

    transient do
      images { [] }
      types { [] }
      manufacturers { [] }
    end
  end
end
