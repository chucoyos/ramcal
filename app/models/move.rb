class Move < ApplicationRecord
  belongs_to :location, optional: true
  belongs_to :container, optional: false
  validates :container_id, presence: true
  has_many_attached :images

  validate :single_entry_and_exit
  validate :different_location_for_reacomodo, if: -> { move_type == "Reacomodo" }
  validate :location_must_be_available, if: -> { location.present? && move_type == "Entrada" }
  validate :no_moves_after_salida, on: :create

  before_create :mark_previous_location_available, if: -> { move_type == "Reacomodo" || move_type == "Salida" }
  after_save :mark_location_unavailable, if: -> { location.present? && (move_type == "Entrada" || move_type == "Reacomodo") }
  after_save :mark_location_available, if: -> { location.present? && move_type == "Salida" }

  private
  # Validation to ensure no moves are allowed after a "Salida"
  def no_moves_after_salida
    if container.moves.exists?(move_type: "Salida")
      errors.add(:base, "El contenedor ya tiene la salida registrada.")
    end
  end

  def different_location_for_reacomodo
    previous_move = container.moves.where.not(id: id).order(created_at: :desc).first
    if previous_move && location_id == previous_move.location_id
      errors.add(:base, "Debe cambiar la ubicación.")
    end
  end

  # Mark the new location as unavailable
  def mark_location_unavailable
    location.update!(available: false)
  end

  # Mark the previous location as available
  def mark_previous_location_available
    previous_move = container.moves.where.not(id: id).order(created_at: :desc).first
    return unless previous_move&.location

    previous_move.location.update!(available: true)
  end

  # Mark the current location as available on "Salida"
  def mark_location_available
    location.update!(available: true)
  end

  # Ensure the location is available before assigning it
  def location_must_be_available
    errors.add(:base, "Esta ubicación no está disponible") unless location.available?
  end

  # Ensure valid sequence of moves
  def single_entry_and_exit
    return unless container

    if move_type == "Entrada" && container.moves.where(move_type: "Entrada").where.not(id: id).exists?
      errors.add(:base, "Solo un movimiento de 'Entrada' está permitido para este contenedor")
    elsif move_type != "Entrada" && !container.moves.exists?(move_type: "Entrada")
      errors.add(:base, "Debe existir un movimiento de 'Entrada' antes de agregar otro tipo de movimiento")
    elsif move_type == "Salida" && container.moves.where(move_type: "Salida").where.not(id: id).exists?
      errors.add(:base, "Solo un movimiento de 'Salida' está permitido para este contenedor")
    end
  end
end
