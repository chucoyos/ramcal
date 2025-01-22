class User < ApplicationRecord
  belongs_to :role
  scope :clients, -> { joins(:role).where(roles: { name: "cliente" }) }
  has_many :pricings
  has_many :services, through: :pricings
  has_many :invoices, dependent: :restrict_with_error
  has_many :containers, dependent: :destroy
  validates :email, presence: true, uniqueness: true
  # validates :password, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :username, presence: true, uniqueness: true

  validates :credit_limit, numericality: { greater_than_or_equal_to: 0 }
  validates :available_credit, numericality: { greater_than_or_equal_to: 0 }
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  def update_available_credit
   self.available_credit = credit_limit - invoices.where(status: "Pendiente").sum(:total)
   save
  end

  # def update_available_credit
  #   pending_total = invoices.where(status: "Pendiente").sum(:total)
  #   partial_total = invoices.where(status: "Parcial").sum { |invoice| invoice.total - invoice.payments.sum(:amount).to_f }

  #   self.available_credit = credit_limit - (pending_total + partial_total)
  #   save!
  # end

  # def update_available_credit
  #   pending_total = invoices.where(status: "Pendiente").sum(:total)
  #   partial_total = invoices.where(status: "Parcial").sum { |invoice| invoice.total - invoice.payments.sum(:amount) }

  #   new_available_credit = credit_limit - (pending_total + partial_total)

  #   Rails.logger.info "Updating available credit: Old: #{available_credit}, New: #{new_available_credit}"

  #   update!(available_credit: new_available_credit)
  # end

  # def update_available_credit
  #   pending_total = invoices.where(status: "Pendiente").sum(:total).to_f
  #   partial_total = invoices.where(status: "Parcial").sum { |invoice| invoice.total - invoice.payments.sum(:amount).to_f }

  #   new_available_credit = credit_limit - (pending_total + partial_total)

  #   update_column(:available_credit, new_available_credit) # Direct DB update
  # end

  def full_name
    "#{first_name} #{last_name} #{second_last_name}"
  end
end
