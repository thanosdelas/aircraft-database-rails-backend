# frozen_string_literal: true

module Admin
  class AdminController < ApplicationController
    before_action :authorize

    private

    def authorize
      redirect_to root_path unless user.admin?
    end
  end
end
