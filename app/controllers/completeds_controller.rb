class CompletedsController < ApplicationController
  before_action :set_notification, only: [ :update ]

  def update
    @notification.completed = !@notification.completed
    @notification.save
  end

  private
  def set_notification
    @notification = Notification.find(params[:notification_id])
  end
end
