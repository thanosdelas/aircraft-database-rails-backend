# frozen_string_literal: true

class User < ApplicationRecord
  belongs_to :group, :class_name => 'UserGroup', foreign_key: 'user_group_id'

  has_secure_password

  validates :user_group_id, presence: false, allow_nil: true
  validates :username, allow_nil: true, uniqueness: true
  validates :email, presence: true, uniqueness: true

  before_validation :set_default_user_group_if_not_set

  def admin?
    group.group == 'admin'
  end

  private

  def set_default_user_group_if_not_set
    self.group ||= UserGroup.find_by('group' => 'guest')
  end
end
