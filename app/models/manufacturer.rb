# frozen_string_literal: true

class Manufacturer < ApplicationRecord
  self.table_name = 'manufacturers'

  has_many :aircraft_manufacturers, class_name: 'AircraftManufacturer', dependent: :restrict_with_error
  has_many :aircraft, class_name: 'Aircraft', through: :aircraft_manufacturers, dependent: :restrict_with_error

  validates :manufacturer, presence: true, allow_nil: false
end
