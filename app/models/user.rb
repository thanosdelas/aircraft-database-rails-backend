# frozen_string_literal: true

class User < ApplicationRecord
  belongs_to :user_group

  has_secure_password

  validates :user_group_id, presence: false, allow_nil: true
  validates :username, allow_nil: true, uniqueness: true
  validates :email, presence: true, uniqueness: true

  before_validation :set_default_user_group_if_not_set

  def admin?
    user_group.group == 'admin'
  end

  private

  def set_default_user_group_if_not_set
    self.user_group ||= UserGroup.find_by('group' => 'guest')
  end
end
