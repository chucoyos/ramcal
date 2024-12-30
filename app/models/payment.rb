class Payment < ApplicationRecord
  belongs_to :invoice
  MEANS = %w[ Transferencia Cheque Tarjeta Efectivo ].freeze

  validate :amount_cannot_be_greater_than_total
  after_save :update_invoice, if: -> { invoice.payments.sum(:amount) >= invoice.total }
  after_destroy_commit :update_invoice if -> { invoice.payments.sum(:amount) < invoice.total }


  private

  def update_invoice
    if invoice.payments.sum(:amount) >= invoice.total
      invoice.update(status: "Pagada")
    else
      invoice.update(status: "Pendiente")
    end
  end

  def amount_cannot_be_greater_than_total
    if amount.present? && invoice.present? && (amount + invoice.payments.sum(:amount)) > invoice.total
      errors.add(:amount, "El pago no puede ser mayor al total de la factura")
    end
  end
end
