class UsersController < ApplicationController
  before_action :authenticate_user!

  def index
    authorize current_user, :index?, policy_class: UserPolicy
    @users = User.includes(:role).order(:first_name).page(params[:page]).per(10)
  end

  def new
    authorize current_user, :create?, policy_class: UserPolicy
    @user = User.new
    @roles = Role.all
  end

  def create
    authorize current_user, :create?, policy_class: UserPolicy
    @user = User.new(user_params)
    if @user.save
      redirect_to users_path, notice: "User was successfully created."
    else
      render :new, status: :unprocessable_entity
      flash.now[:alert] = "User was not created."
    end
  end

  def show
    authorize current_user, :show?, policy_class: UserPolicy
    @user = User.find(params[:id])
    @invoices = @user.invoices.order(created_at: :desc).page(params[:page])

    # Apply filters
    if params[:status].present?
      @invoices = @invoices.where(status: params[:status])
    end

    if params[:from_date].present?
      @invoices = @invoices.where("issue_date >= ?", params[:from_date])
    end

    if params[:to_date].present?
      @invoices = @invoices.where("issue_date <= ?", params[:to_date])
    end

    @invoices = @invoices.page(params[:page]).per(10)
  end

  def edit
    authorize current_user, :update?, policy_class: UserPolicy
    @user = User.find(params[:id])
  end

  def update
    authorize current_user, :update?, policy_class: UserPolicy
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to user_path(@user), notice: "Se actualizó el usuario."
    else
      render :edit, status: :unprocessable_entity
      flash.now[:alert] = "No se actualizó el usuario."
    end
  end

  def destroy
    authorize current_user, :destroy?, policy_class: UserPolicy
    @user = User.find(params[:id])
    if @user.destroy
      redirect_to users_path, notice: "User was successfully deleted."
    else
      redirect_to users_path, alert: @user.errors.full_messages.to_sentence
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :first_name, :last_name, :second_last_name, :username, :phone, :user_type, :contact_person, :role_id, :credit_limit, :available_credit)
  end
end
