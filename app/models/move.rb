class Move < ApplicationRecord
  belongs_to :location, optional: true
  belongs_to :container, optional: false
  validates :container_id, presence: true
  has_many_attached :images

  validate :single_entry_and_exit

  validate :location_must_be_available, if: -> { location.present? && move_type == "Entrada" }

  after_create :mark_location_unavailable, if: -> { location.present? && move_type == "Entrada" }
  after_create :mark_location_available, if: -> { location.present? && move_type == "Salida" }


  private

  def mark_location_unavailable
    location.update!(available: false)
  end

  def mark_location_available
    location.update!(available: true)
  end

  def location_must_be_available
    errors.add(:location, "No disponible") unless location.available?
  end

  def single_entry_and_exit
    return unless container

    if move_type == "Entrada" && container.moves.where(move_type: "Entrada").where.not(id: id).exists?
      errors.add(:move_type, "Solo un movimiento de 'Entrada' está permitido para este contenedor")
    elsif move_type != "Entrada" && !container.moves.exists?(move_type: "Entrada")
      errors.add(:move_type, "Debe existir un movimiento de 'Entrada' antes de agregar otro tipo de movimiento")
    elsif move_type == "Salida" && container.moves.where(move_type: "Salida").where.not(id: id).exists?
      errors.add(:move_type, "Solo un movimiento de 'Salida' está permitido para este contenedor")
    end
  end
end
