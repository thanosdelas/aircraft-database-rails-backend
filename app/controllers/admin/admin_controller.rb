module Admin
  class AdminController < ApplicationController
    before_action :authorize

    private

    def authorize
      redirect_to root_path unless user.is_admin?
    end
  end
end
