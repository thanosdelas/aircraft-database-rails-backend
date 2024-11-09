# frozen_string_literal: true

class Type < ApplicationRecord
  self.table_name = 'types'

  has_many :aircraft_types, class_name: 'AircraftType', dependent: :restrict_with_error
  has_many :aircraft, class_name: 'Aircraft', through: :aircraft_types, dependent: :restrict_with_error

  validates :aircraft_type, presence: true, allow_nil: false

  default_scope { order(id: :asc) }
end
