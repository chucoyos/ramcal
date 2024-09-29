class Container < ApplicationRecord
  belongs_to :user
  validates :size, inclusion: { in: %w[20 40],
                                message: "%{value} no es un tamaño válido" }
end
