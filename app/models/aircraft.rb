# frozen_string_literal: true

class Aircraft < ApplicationRecord
  self.table_name = 'aircraft'

  has_many :aircraft_images, dependent: :restrict_with_error
end
