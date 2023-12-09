class LoginController < ApplicationController
  before_action :redirect_if_logged_in?

  def create
    @user = User.find_by(email: params[:email])

    if @user && @user.authenticate(params[:password])
      session[:user_id] = @user.id

      return redirect_to user_page_path
    end

    flash[:alert] = "Login failed"
    redirect_to root_path
  end

  private

  def redirect_if_logged_in?
    redirect_to user_page_path if logged_in?
  end
end
