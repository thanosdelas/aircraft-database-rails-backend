# frozen_string_literal: true

class ManufacturerGroup < ApplicationRecord
  self.table_name = 'manufacturer_groups'

  has_many :manufacturers, class_name: 'Manufacturer', dependent: :restrict_with_error

  validates :manufacturer_group, presence: true, allow_nil: false
end
