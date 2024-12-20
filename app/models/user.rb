class User < ApplicationRecord
  belongs_to :role
  scope :clients, -> { joins(:role).where(roles: { name: "cliente" }) }
  has_many :pricings
  has_many :services, through: :pricings
  has_many :invoices
  validates :email, presence: true, uniqueness: true
  # validates :password, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :username, presence: true, uniqueness: true
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  def full_name
    "#{first_name} #{last_name} #{second_last_name}"
  end
end
