class Service < ApplicationRecord
  NAMES = [ "Camión a Piso", "Piso a Camión", "Lavado", "Traspaleo", "Almacenaje" ].freeze

  belongs_to :container
end
