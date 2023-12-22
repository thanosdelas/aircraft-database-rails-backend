# frozen_string_literal: true

class UserController < AuthController
  def delete
    reset_session

    redirect_to root_path
  end
end
