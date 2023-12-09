class ApplicationController < ActionController::Base
  def auth
    redirect_to root_path unless logged_in?
  end

  def logged_in?
    user.present?
  end

  def user
    return @user if instance_variable_defined?(:@user)

    @user ||= session[:user_id] && User.find_by(id: session[:user_id])
  end
end
