class User < ApplicationRecord
  has_secure_password

  validates :username, allow_nil: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true
end
