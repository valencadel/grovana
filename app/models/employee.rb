class Employee < ApplicationRecord
  belongs_to :company

  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable

  # Estados posibles
  VALID_STATUSES = %w[active inactive].freeze
  # Roles posibles
  VALID_ROLES = %w[Manager Employee].freeze

  validates :first_name, :last_name, presence: true
  validates :status, inclusion: { in: VALID_STATUSES, message: "%{value} is not a valid status" }
  validates :role, inclusion: { in: VALID_ROLES, message: "%{value} is not a valid role" }
  validates :email, uniqueness: { scope: :company_id }

  # Status y role por defecto
  after_initialize :set_defaults, if: :new_record?

  def full_name
    "#{first_name} #{last_name}"
  end

  def active?
    status == 'active'
  end

  # Validar que el empleado esté activo antes de iniciar sesión
  def active_for_authentication?
    super && active?
  end

  # Mensaje cuando el empleado está inactivo
  def inactive_message
    "Your account is inactive. Please contact your administrator."
  end

  private

  def set_defaults
    self.status ||= 'active'
    self.role ||= 'Employee'
  end
end
