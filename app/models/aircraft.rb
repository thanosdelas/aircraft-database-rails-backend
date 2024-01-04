# frozen_string_literal: true

class Aircraft < ApplicationRecord
  self.table_name = 'aircraft'

  has_many :images, class_name: 'AircraftImage', dependent: :restrict_with_error

  validates :model, presence: true, allow_nil: false

  default_scope { order(id: :asc) }
end
