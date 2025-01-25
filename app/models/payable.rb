class Payable < ApplicationRecord
  PAYMENT_TYPES = [ "Pago", "Pago sin soporte", "Gasto a comprobar", "Comprobación sin soporte",
                    "Comprobación de gastos", "Devolución", "Nómina" ].freeze

  PAYMENT_MEANS = [ "Efectivo", "Transferencia", "Cheque", "Tarjeta" ].freeze

  belongs_to :supplier
  belongs_to :user

  # validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :payment_type, presence: true, inclusion: { in: PAYMENT_TYPES }
  validates :payment_means, presence: true, inclusion: { in: PAYMENT_MEANS }
  validates :payment_concept, presence: true
  validates :payment_date, presence: true
end
