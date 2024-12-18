# frozen_string_literal: true

class User < ApplicationRecord
  belongs_to :group, class_name: 'UserGroup', foreign_key: 'user_group_id', inverse_of: :users

  has_secure_password validations: false
  validate :password_presence_if_google_sub_is_not_provided

  validates :user_group_id, presence: false, allow_nil: true
  validates :username, allow_nil: true, uniqueness: true
  validates :email, presence: true, uniqueness: true

  before_validation :set_default_user_group_if_not_set

  def admin?
    group.group == 'admin'
  end

  private

  def set_default_user_group_if_not_set
    self.group ||= UserGroup.find_by(group: 'user')
  end

  def password_presence_if_google_sub_is_not_provided
    return if google_sub.present?

    if password_digest.blank?
      errors.add(:password, "can't be blank")
    elsif password.blank?
      errors.add(:password, 'must be provided')
    end
  end
end
