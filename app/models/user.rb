class User < ApplicationRecord
  belongs_to :role
  validates :email, presence: true, uniqueness: true
  validates :first_name, presence: true
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
