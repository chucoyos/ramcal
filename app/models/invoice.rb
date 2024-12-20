class Invoice < ApplicationRecord
  belongs_to :user
  has_many :services

  validates :user_id, presence: true
  validates :status, inclusion: { in: %w[ Pending Paid Overdue ] }
end
