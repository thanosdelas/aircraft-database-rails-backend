# frozen_string_literal: true

class AircraftImage < ApplicationRecord
  self.table_name = 'aircraft_images'

  belongs_to :aircraft, class_name: 'Aircraft'

  validates :aircraft_id, presence: false
  validates :url, presence: true, allow_nil: false
  validates :url, uniqueness: { scope: :aircraft_id, message: 'This url is already used for this aircraft' }

  validates :filename, presence: true
end
