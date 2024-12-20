class Move < ApplicationRecord
  MOVE_TYPES = %w[Entrada Reacomodo Traspaleo Lavado Salida].freeze

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
  after_create :set_up_invoice, if: -> { move_type == "Salida" }

  private

  def set_up_invoice
    user = container.user
    services = container.services.where(invoiced: false)

    nil unless user && services.any?

    invoice = Invoice.create!(
      user: user,
      total: services.sum(&:charge),
      status: "Pending",
      issue_date: Date.today,
      due_date: Date.today + 30.days
    )

    services.each { |service| service.update!(invoice: invoice, invoiced: true) }
  end

  def create_related_service
      # Map move_type to service name
      case move_type
      when "Entrada", "Traspaleo", "Lavado"
        create_regular_service(move_type_to_service_name)
      when "Salida"
        create_regular_service("Piso-Camión")
        create_stay_service
        handle_service_cleanup if container.moves.exists?(move_type: "Traspaleo")
      end
  end

  def create_regular_service(service_name)
    # Ensure the service name is derived from the move type
    service_name = move_type_to_service_name

    # Retrieve the service and service ID
    service = Service.find_by(name: service_name, container_id: nil)
    service_id = service&.id

    # Find client-specific pricing
    pricing = container.user&.pricings&.find_by(service_id: service_id)

    # Determine the charge (prioritize client-specific pricing, then service template charge, fallback to 0)
    charge = pricing&.price || service&.charge || 0

    # Raise an error if the service is not properly defined
    unless service
      Rails.logger.error "Service not found for name: #{service_name}"
      raise ActiveRecord::RecordNotFound, "Service not found for name: #{service_name}"
    end

    # Create the service for the container
    self.container.services.create!(
      name: service_name,
      charge: charge,
      invoiced: false,
      start_date: Date.today,
      end_date: Date.today
    )
  end

  def handle_service_cleanup
    # Fetch all services for the container except 'Camión-Camión'
    container.services.where.not(name: "Camión-Camión").destroy_all
  end

  def create_stay_service
    entry_move = container.moves.find_by(move_type: "Entrada")
    nil unless entry_move

    pricing = container.user.pricings.find_by(
      user_id: container.user.id,
      service_id: Service.find_by(name: "Almacenaje")&.id
    )

    calculator = StayServiceCalculator.new(container, pricing)

    charge = calculator.calculate_charge

    # Create the service for this container
    self.container.services.create!(
      name: "Almacenaje",
      charge: charge,
      invoiced: false,
      start_date: entry_move.created_at,
      end_date: Date.today,
    )
  end

  # Helper to map move_type to service name
  def move_type_to_service_name
    case move_type
    when "Entrada" then "Camión-Piso"
    when "Salida" then "Piso-Camión"
    when "Traspaleo" then "Camión-Camión"
    when "Lavado" then "Lavado"
    end
  end

  def location_changed_for_types?
    # Check if the location has changed for Traspaleo or Lavado moves
    # (move_type == "Traspaleo" || move_type == "Lavado") && location_id_changed?
    (move_type == "Traspaleo" || move_type == "Lavado" || move_type == "Reacomodo") && location_id_changed?
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

    previous_move.location.update!(available: true) if previous_move.location != location
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
