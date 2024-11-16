class Employee < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable
  belongs_to :company

  validates :first_name, :last_name, :email, :role, presence: true
  validates :status, inclusion: { in: %w[active inactive], message: "%{value} no es un estado válido" }
end
