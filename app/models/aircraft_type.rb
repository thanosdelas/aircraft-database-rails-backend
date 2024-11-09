# frozen_string_literal: true

class AircraftType < ApplicationRecord
  self.table_name = 'aircraft_types'

  belongs_to :aircraft
  belongs_to :type
end
