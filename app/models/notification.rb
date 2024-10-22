class Notification < ApplicationRecord
  belongs_to :move
  validates :message, presence: true
  validates :completed, inclusion: { in: [ true, false ] }
  after_commit -> { broadcast_prepend_to "notifications" }, on: :create
  after_commit -> { broadcast_replace_to "notifications" }, on: :update
  after_commit -> { broadcast_remove_to "notifications" }, on: :destroy
end
