class Service < ApplicationRecord
  NAMES = %w[Camión-Piso Piso-Camión Camión-Camión Almacenaje Lavado Reacomodo].freeze

  scope :unbilled, -> { where(invoiced: false) }

  belongs_to :container, optional: true
  belongs_to :invoice, optional: true
  has_many :pricings
  has_many :users, through: :pricings
  validates :name, presence: true, inclusion: { in: NAMES }
  # add validation to prevent deletion or editing of a service that has been invoiced
  before_destroy :check_invoiced
  before_update :check_invoiced

  def check_invoiced
    if invoiced
      errors.add(:base, "No se puede editar o eliminar un servicio facturado")
      throw(:abort)
    end
  end
end
