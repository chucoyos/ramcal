class Move < ApplicationRecord
  belongs_to :container, optional: false
  validates :container_id, presence: true
  has_many_attached :images

  validate :single_entry_and_exit

  private

  def single_entry_and_exit
    return unless container

    if move_type == "Entrada" && container.moves.where(move_type: "Entrada").where.not(id: id).exists?
      errors.add(:move_type, "Solo un movimiento de 'Entrada' está permitido para este contenedor")
    elsif move_type == "Salida" && container.moves.where(move_type: "Salida").where.not(id: id).exists?
      errors.add(:move_type, "Solo un movimiento de 'Salida' está permitido para este contenedor")
    end
  end
end
