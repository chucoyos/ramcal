class ChangeMessageTypeInNotifications < ActiveRecord::Migration[7.2]
  def change
    change_column :notifications, :message, :string
  end
end
