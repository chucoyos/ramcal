class UsersController < ApplicationController
  before_action :authenticate_user!
  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
  end


  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to user_path(@user), notice: "User was successfully updated."
    else
      render :edit, status: :unprocessable_entity
      flash.now[:alert] = "User was not updated."
    end
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :second_last_name, :username, :phone, :user_type, :contact_person)
  end
end
