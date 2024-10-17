class Location < ApplicationRecord
  has_many :moves
  validates :section, :row, :position, :tier, presence: true

  scope :available, -> { where(available: true) }

  def full_description
    "Section: #{section}, Fila: #{row}, Bahía: #{position}, Estiba: #{tier}"
  end
end
