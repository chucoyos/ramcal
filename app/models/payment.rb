class Payment < ApplicationRecord
  belongs_to :invoice
  MEANS = %w[ Transferencia Cheque Tarjeta Efectivo ].freeze
end
