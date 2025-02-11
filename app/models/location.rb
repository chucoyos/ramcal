class Location < ApplicationRecord
  CAPACITIES = [ 0, 20, 40 ].freeze
  has_many :moves
  validates :location, presence: true, uniqueness: true
  validates :capacity, presence: true, inclusion: { in: CAPACITIES, message: "Debe ser 0, 20 o 40" }

  validate :capacity_cannot_exceed_max
  validate :capacity_cannot_be_negative

  scope :available, -> { where(available: true) }

  def full_description
    location
  end

  def location_with_capacity
    "(#{capacity}) #{location}"
  end

  private

  def capacity_cannot_exceed_max
    if capacity.present? && capacity > 40
      errors.add(:capacity, "La capacidad no puede ser mayor a 40")
    end
  end

  def capacity_cannot_be_negative
    if capacity.present? && capacity < 0
      errors.add(:capacity, "La capacidad no puede ser menor a 0")
    end
  end
end
