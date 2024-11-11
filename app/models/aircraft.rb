# frozen_string_literal: true

class Aircraft < ApplicationRecord
  self.table_name = 'aircraft'

  has_many :images, class_name: 'AircraftImage', dependent: :restrict_with_error

  has_many :aircraft_types, class_name: 'AircraftType', dependent: :restrict_with_error
  has_many :types, class_name: 'Type', through: :aircraft_types, dependent: :restrict_with_error

  has_many :aircraft_manufacturers, class_name: 'AircraftManufacturer', dependent: :restrict_with_error
  has_many :manufacturers, class_name: 'Manufacturer', through: :aircraft_manufacturers, dependent: :restrict_with_error

  validates :model, presence: true, allow_nil: false
end
