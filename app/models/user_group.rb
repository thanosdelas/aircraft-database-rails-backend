# frozen_string_literal: true

class UserGroup < ApplicationRecord
  has_many :users, dependent: :restrict_with_error

  validates :group, presence: true, uniqueness: true
end
