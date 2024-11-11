# frozen_string_literal: true

class AircraftManufacturer < ApplicationRecord
  self.table_name = 'aircraft_manufacturers'

  belongs_to :aircraft
  belongs_to :manufacturer
end
