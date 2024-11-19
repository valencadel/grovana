class EmployeesController < ApplicationController
  before_action :authenticate_any!
  before_action :set_employee, only: [:show, :edit, :update]

  def index
    authorize Employee

    @company = if current_user
                current_user.companies.first
              else
                current_employee&.company
              end

    # Redirigir a perfil si es un empleado regular
    if current_employee && !user_is_manager?
      redirect_to profile_employees_path
      return
    end

    @employees = policy_scope(@company.employees).order(role: :desc, first_name: :asc)
  end

  def show
    authorize @employee
  end

  def new
    @employee = Employee.new
    authorize @employee
  end

  def edit
    authorize @employee
  end

  def create
    @employee = Employee.new(employee_params)
    @employee.company = current_user.companies.first
    authorize @employee

    if @employee.save
      redirect_to employees_path, notice: 'Empleado creado exitosamente.'
    else
      flash.now[:alert] = 'Error al crear el empleado.'
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @employee

    if @employee.update(employee_params)
      redirect_to employees_path, notice: 'Empleado actualizado exitosamente.'
    else
      flash.now[:alert] = 'Error al actualizar el empleado.'
      render :edit, status: :unprocessable_entity
    end
  end

  def profile
    @employee = current_employee
    authorize @employee, :profile?
  end

  def edit_password
    @employee = current_employee
    authorize @employee, :edit_password?
  end

  def update_password
    @employee = current_employee
    authorize @employee, :update_password?

    if @employee.update_with_password(password_params)
      bypass_sign_in(@employee)
      redirect_to profile_employees_path, notice: 'Contraseña actualizada exitosamente.'
    else
      # Mostrar errores específicos
      error_messages = @employee.errors.full_messages.join(', ')
      Rails.logger.debug "Errores de validación: #{error_messages}"
      flash.now[:alert] = "Error al actualizar la contraseña: #{error_messages}"
      render :edit_password, status: :unprocessable_entity
    end
  rescue => e
    Rails.logger.error "Error actualizando contraseña: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    flash.now[:alert] = "Error al actualizar la contraseña: #{e.message}"
    render :edit_password, status: :unprocessable_entity
  end

  private

  def set_employee
    @employee = if current_user
                 current_user.companies.first.employees.find(params[:id])
               else
                 current_employee.company.employees.find(params[:id])
               end
  rescue ActiveRecord::RecordNotFound
    redirect_to employees_path, alert: 'Empleado no encontrado'
  end

  def employee_params
    permitted_params = [:first_name, :last_name, :email]

    if current_user&.companies&.exists?
      permitted_params += [:role, :status, :password, :password_confirmation]
    end

    params.require(:employee).permit(permitted_params)
  end

  def password_params
    params.require(:employee).permit(:current_password, :password, :password_confirmation)
  end

  def user_is_manager?
    current_employee&.role == 'Manager'
  end
end
