class Move < ApplicationRecord
  MOVE_TYPES = %w[Entrada Salida Reacomodo Traspaleo Lavado].freeze

  belongs_to :created_by, class_name: "User", optional: true
  belongs_to :location, optional: true
  belongs_to :container, optional: false

  has_many :notifications, dependent: :destroy
  has_many_attached :images

  validates :container_id, presence: true

  validate :single_entry_and_exit
  validate :location_must_be_available, if: -> { location.present? && move_type == "Entrada" }
  validate :no_moves_after_salida, on: :create

  before_destroy :mark_location_available, if: -> { location.present? }
  before_create :mark_previous_location_available, if: -> { location_changed_for_types? }
  after_save :mark_location_unavailable, if: -> { location.present? && (move_type == "Entrada" || move_type == "Reacomodo" || location_changed_for_types?) }
  after_save :mark_location_available, if: -> { location.present? && move_type == "Salida" }
  after_create :create_related_service

  private

  def create_related_service
    case move_type
    when "Entrada"
      self.container.services.create!(name: "Camión a Piso", charge: 100, invoiced: false, start_date: Date.today)
    when "Salida"
      self.container.services.create!(name: "Piso a Camión", charge: 100, invoiced: false, start_date: Date.today)
    when "Traspaleo"
      self.container.services.create!(name: "Traspaleo", charge: 100, invoiced: false, start_date: Date.today)
    end
  end

  def location_changed_for_types?
    # Check if the location has changed for Traspaleo or Lavado moves
    (move_type == "Traspaleo" || move_type == "Lavado") && location_id_changed?
  end

  # Validation to ensure no moves are allowed after a "Salida"
  def no_moves_after_salida
    if container.moves.exists?(move_type: "Salida")
      errors.add(:base, "El contenedor ya tiene la salida registrada.")
    end
  end

  # Mark the new location as unavailable
  def mark_location_unavailable
    location.update!(available: false)
  end

  def mark_location_available
    location.update!(available: true)
  end

  # Mark the previous location as available
  def mark_previous_location_available
    previous_move = container.moves.where.not(id: id).order(created_at: :desc).first
    return unless previous_move&.location

    previous_move.location.update!(available: true)
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
