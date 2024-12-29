class Invoice < ApplicationRecord
  STATUSES = %w[ Pendiente Pagada Vencida ].freeze
  belongs_to :user
  has_many :services
  has_many :payments, dependent: :destroy

  validates :user_id, presence: true
  validates :status, inclusion: { in: %w[ Pendiente Pagada Vencida ] }
  before_destroy :update_services

  private

  def update_services
    services.update_all(invoice_id: nil, invoiced: false) if services.exists?
  end
end
