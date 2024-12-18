class NotificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_notification, only: %i[ show edit update destroy ]

  # GET /notifications or /notifications.json
  def index
    authorize current_user, :index?, policy_class: NotificationPolicy
    # @notifications = Notification.order(created_at: :desc).page(params[:page]).per(10)
    @notifications = Notification.includes(move: [ :location, :container ]).order(created_at: :desc).page(params[:page]).per(10)
    @notification = Notification.new
  end

  # GET /notifications/1 or /notifications/1.json
  def show
    authorize current_user, :show?, policy_class: NotificationPolicy
  end

  # GET /notifications/new
  def new
    authorize current_user, :create?, policy_class: NotificationPolicy
    @notification = Notification.new
  end

  # GET /notifications/1/edit
  def edit
    authorize current_user, :update?, policy_class: NotificationPolicy
  end

  # POST /notifications or /notifications.json
  def create
    authorize current_user, :create?, policy_class: NotificationPolicy
    @notification = Notification.new(notification_params)

    if @notification.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to projects_path, notice: "Notification was successfully created." }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace(@notification, partial: "notifications/form", locals: { notification: @notification }) }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /notifications/1 or /notifications/1.json
  def update
    authorize current_user, :update?, policy_class: NotificationPolicy
    respond_to do |format|
      if @notification.update(notification_params)
        format.html { redirect_to @notification, notice: "Notification was successfully updated." }
        format.json { render :show, status: :ok, location: @notification }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @notification.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /notifications/1 or /notifications/1.json
  def destroy
    authorize current_user, :destroy?, policy_class: NotificationPolicy
    @notification.destroy!

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@notification) }
      format.html { redirect_to notifications_path, notice: "Notification deleted." }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_notification
      @notification = Notification.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def notification_params
      params.require(:notification).permit(:message, :completed, :move_id)
    end
end
