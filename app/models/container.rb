class Container < ApplicationRecord
  has_many :eirs, dependent: :destroy
  has_many :moves, dependent: :destroy
  belongs_to :user
  validates :size, inclusion: { in: %w[20 40],
                                message: "%{value} no es un tamaño válido" }
end
