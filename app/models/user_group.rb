# frozen_string_literal: true

class UserGroup < ApplicationRecord
  validates :group, presence: true, uniqueness: true
end
