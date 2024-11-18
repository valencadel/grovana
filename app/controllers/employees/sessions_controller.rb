class Employees::SessionsController < Devise::SessionsController
  before_action :authenticate_employee!, except: [:new, :create, :destroy]

  def profile
    @employee = current_employee
  end

  def edit_password
    @employee = current_employee
    set_minimum_password_length if respond_to?(:set_minimum_password_length)
  end

  def update_password
    @employee = current_employee
    if @employee.update_with_password(password_params)
      bypass_sign_in(@employee)
      flash[:notice] = "Contraseña actualizada exitosamente."
      redirect_to employees_profile_path
    else
      set_minimum_password_length if respond_to?(:set_minimum_password_length)
      render :edit_password
    end
  end

  private

  def password_params
    params.require(:employee).permit(:current_password, :password, :password_confirmation)
  end
end
