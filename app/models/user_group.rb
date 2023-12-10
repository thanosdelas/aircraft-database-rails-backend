class UserGroup < ApplicationRecord
  validates :group, presence: true, uniqueness: true
end
