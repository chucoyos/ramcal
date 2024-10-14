class Container < ApplicationRecord
  has_many :eirs, dependent: :destroy
  has_many :moves, dependent: :destroy
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
