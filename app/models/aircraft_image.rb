# frozen_string_literal: true

class AircraftImage < ApplicationRecord
  self.table_name = 'aircraft_images'

  belongs_to :aircraft, class_name: 'Aircraft'

  validates :aircraft_id, presence: false, allow_nil: true
  validates :url, allow_nil: true, uniqueness: true
  validates :filename, presence: true, uniqueness: true
end
