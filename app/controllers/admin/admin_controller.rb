module Admin
  class AdminController < ApplicationController
    def is_admin?
      redirect_to root_path unless user.is_admin?
    end
  end
end
