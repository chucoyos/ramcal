class Container < ApplicationRecord
  CONTAINER_TYPES = [
    [ "Estándar", "Estándar" ],
    [ "Seco", "Seco" ],
    [ "Refrigerado", "Refrigerado" ],
    [ "Open Top", "Open Top" ],
    [ "Flat Rack", "Flat Rack" ],
    [ "High Cube", "High Cube" ],
    [ "Tanque", "Tanque" ],
    [ "Otro", "Otro" ]
  ].freeze

  has_many :eirs, dependent: :destroy
  has_many :moves, dependent: :destroy
  has_many :services, dependent: :destroy
  has_many :invoices, through: :services
  belongs_to :user
  before_save :upcase_number
  validates :number, presence: true, format: { with: /\A[A-Z]{4}\d{7}\z/i,
                                                message: "Deben ser 4 letras mayúsculas y 7 números sin espacios" }
  validates :size, presence: true
  validates :size, inclusion: { in: %w[20 40],
                                message: "%{value} no es un tamaño válido" }
  private

  def upcase_number
    self.number = number.upcase
  end
end
