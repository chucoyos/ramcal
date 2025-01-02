class Invoice < ApplicationRecord
  STATUSES = %w[ Pendiente Pagada Vencida ].freeze
  belongs_to :user
  belongs_to :container, optional: true
  has_many :services
  has_many :payments, dependent: :destroy

  validates :user_id, presence: true
  validates :status, inclusion: { in: %w[ Pendiente Pagada Vencida ] }
  before_destroy :prevent_destroy

  def clear_services
    if frozen?
      errors.add(:base, "Cannot clear services for a frozen invoice.")
      throw(:abort)
    end

    if services.exists?
      services.update_all(invoice_id: nil, invoiced: false)
    end
  end

  private

  def prevent_destroy
    errors.add(:base, "Debe eliminar los pagos antes de eliminar la factura") if payments.exists?
    throw(:abort) if errors.present?
  end
end
