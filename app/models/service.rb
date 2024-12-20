class Service < ApplicationRecord
  NAMES = %w[Camión-Piso Piso-Camión Camión-Camión Almacenaje Lavado Reacomodo].freeze

  belongs_to :container, optional: true
  belongs_to :invoice, optional: true
  has_many :pricings
  has_many :users, through: :pricings
  validates :name, presence: true, inclusion: { in: NAMES }
end
