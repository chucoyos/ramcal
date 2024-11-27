class Service < ApplicationRecord
  NAMES = [ "Camión-Piso", "Piso-Camión", "Camión-Camión", "Reacomodo", "Almacenaje" ].freeze

  belongs_to :container, optional: true
end
