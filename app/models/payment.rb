class Payment < ApplicationRecord
  belongs_to :invoice
  MEANS = %w[ Transferencia Cheque Tarjeta Efectivo ].freeze

  validates :amount, presence: true
  validate :amount_cannot_be_greater_than_total
  validate :amount_must_be_positive
  after_save :update_invoice
  after_destroy_commit :update_invoice if -> { invoice.payments.sum(:amount) < invoice.total }

  after_commit :update_user_credit, on: :create
  # after_create :update_user_credit
  private

  def update_user_credit
    invoice.user.update_available_credit
  end

  def update_invoice
    total_payments = invoice.payments.sum(:amount)

    if total_payments >= invoice.total
      invoice.update(status: "Pagada")
    elsif total_payments.positive? && total_payments < invoice.total
      invoice.update(status: "Parcial")
    else
      invoice.update(status: "Pendiente")
    end
  end

  def amount_must_be_positive
    if amount.present? && amount <= 0
      errors.add(:amount, "El pago debe ser mayor a 0")
    end
  end

  def amount_cannot_be_greater_than_total
    if amount.present? && invoice.present? && (amount + invoice.payments.sum(:amount)) > invoice.total
      errors.add(:amount, "El pago no puede ser mayor al total de la factura")
    end
  end
end
