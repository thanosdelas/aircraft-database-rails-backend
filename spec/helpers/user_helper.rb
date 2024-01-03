# frozen_string_literal: true

module UserHelper
  def create_user_groups
    ::UserGroup.create!([
      { id: 100, group: 'admin' },
      { id: 200, group: 'user' },
      { id: 300, group: 'guest' }
    ])
  end
end
