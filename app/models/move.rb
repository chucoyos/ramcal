class Move < ApplicationRecord
  MOVE_TYPES = %w[Entrada Reacomodo Traspaleo Lavado Salida].freeze

  Time.zone = "America/Mexico_City"

  belongs_to :created_by, class_name: "User", optional: true
  belongs_to :location, optional: true
  belongs_to :container, optional: false

  has_many :notifications, dependent: :destroy
  has_many_attached :images

  validates :container_id, presence: true

  validate :single_entry_and_exit
  validate :location_must_be_available, if: -> { location.present? && move_type == "Entrada" }
  validate :location_must_have_capacity, if: -> { location.present? && container.present? }
  validate :no_moves_after_salida, on: :create
  validate :location_must_change_for_certain_moves, if: -> { move_type.in?([ "Reacomodo", "Lavado", "Traspaleo" ]) }

  before_destroy :restore_location_capacity, if: -> { location.present? && container.moves.where(move_type: "Salida").empty? }
  before_create :restore_previous_location_capacity, if: -> { location_changed_for_types? }
  after_save :update_location_capacity, if: -> { location.present? && (move_type != "Salida") }
  after_save :restore_location_capacity, if: -> { location.present? && move_type == "Salida" }
  after_create :create_related_service
  after_create :set_up_invoice, if: -> { move_type == "Salida" && (container.user&.auto_invoice.nil? || container.user&.auto_invoice) }

  private

  def location_must_change_for_certain_moves
    previous_move = container.moves.where.not(id: id).order(created_at: :desc).first
    if previous_move && location_id == previous_move.location_id
      errors.add(:base, "Debe cambiar la ubicación.")
    end
  end

  def location_must_have_capacity
    return unless location && container
    return if move_type == "Salida"

    # A 40' container can only be placed in a location with exactly 40 capacity
    if container.size.to_i == 40 && location.capacity != 40
      errors.add(:location, "No hay espacio para un contenedor de 40 pies en esta ubicación")
    end

    # A 20' container requires at least 20 capacity
    if container.size.to_i == 20 && location.capacity < 20
      errors.add(:location, "No hay espacio para un contenedor de 20 pies en esta ubicación")
    end
  end

  def mark_location_unavailable # CHANGED
    if container.size == 40
      location.update!(capacity: location.capacity - 40) # A 40ft container fully occupies the location
    elsif container.size == 20
      location.update!(capacity: location.capacity - 20) # Reduce capacity by 20 for a 20ft container
    end
  end

  def mark_location_available # CHANGED
    if container.size == 40
      location.update!(capacity: location.capacity + 40) # Reset capacity for 40ft container leaving
    elsif container.size == 20
      location.update!(capacity: location.capacity + 20) # Increase capacity by 20 when a 20ft container leaves
    end
  end

  def set_up_invoice
    user = container.user
    services = container.services.where(invoiced: false)

    return unless user && services.any?

    invoice = Invoice.create!(
      user: user,
      total: services.sum(&:charge),
      status: "Pendiente",
      issue_date: Time.zone.today,
      due_date: Time.zone.today + 30.days,
    )

    services.each { |service| service.update!(invoice: invoice, invoiced: true) }
  end


  def create_related_service
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
    service = Service.find_by(name: service_name, container_id: nil)
    service_id = service&.id
    pricing = container.user&.pricings&.find_by(service_id: service_id)
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
    return unless entry_move

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
      start_date: entry_move.move_date || entry_move.created_at,
      end_date: Date.today
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
    (move_type == "Traspaleo" || move_type == "Lavado" || move_type == "Reacomodo") && location_id_changed?
  end

  # Validation to ensure no moves are allowed after a "Salida"
  def no_moves_after_salida
    if container.moves.exists?(move_type: "Salida")
      errors.add(:base, "El contenedor ya tiene la salida registrada.")
    end
  end

  def update_location_capacity
    return unless location

    required_capacity = container.size.to_i == 40 ? 40 : 20
    new_capacity = location.capacity - required_capacity

    location.update!(capacity: new_capacity, available: new_capacity > 0)
  end

  def restore_location_capacity
    return unless location

    # Check if there's already a 'Salida' move for this container
    if container.moves.where(move_type: "Salida").where.not(id: id).exists?
      return # Do nothing if the container has already left
    end

    restored_capacity = container.size.to_i == 40 ? 40 : 20
    new_capacity = location.capacity + restored_capacity

    # Ensure the new capacity does not exceed 40
    location.update!(capacity: [ 40, new_capacity ].min, available: true)
  end

  def restore_previous_location_capacity
    previous_move = container.moves.where.not(id: id).order(created_at: :desc).first
    return unless previous_move&.location

    if previous_move.container.size == "40"
      previous_move.location.update!(capacity: 40, available: true)
    elsif previous_move.container.size == "20"
      new_capacity = previous_move.location.capacity + 20
      previous_move.location.update!(capacity: new_capacity, available: true)
    end
  end

  def location_must_be_available
    errors.add(:base, "Esta ubicación no está disponible") unless location.available?
  end

  # Mark the new location as unavailable
  # def mark_location_unavailable
  #   location.update!(available: false)
  # end

  # Ensure the location is available before assigning it
  # def location_must_be_available
  #   errors.add(:base, "Esta ubicación no está disponible") unless location.available?
  # end

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
