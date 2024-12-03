class Service < ApplicationRecord
  NAMES = [ "Camión-Piso", "Piso-Camión", "Camión-Camión", "Reacomodo", "Almacenaje" ].freeze

  belongs_to :container, optional: true
  has_many :pricings
  has_many :users, through: :pricings
  validates :name, presence: true, inclusion: { in: NAMES }
end
