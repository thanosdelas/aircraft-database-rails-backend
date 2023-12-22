# frozen_string_literal: true

module Admin
  class UsersController < Admin::AdminController
    def index
      @users = User.all
    end

    def show
      @user = User.find(params[:id])
    end

    def new
      @user = User.new
      @user.user_group = UserGroup.find_by(group: 'guest')

      @user
    end

    def create
      @user = User.new(user_params)

      if @user.save
        redirect_to admin_users_path
      else
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      @user = User.find(params[:id])
      @user.destroy

      redirect_to admin_users_path
    end

    private

    def user_params
      params.require(:user).permit(:email, :password, :user_group_id)
    end
  end
end
