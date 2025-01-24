class Payable < ApplicationRecord
  PAYMENT_TYPES = [ "Pago", "Pago sin soporte", "Gasto a comprobar", "Comprobación sin soporte",
                    "Comprobación de gastos", "Devolución", "Nómina" ].freeze

  belongs_to :supplier
  belongs_to :user
end
