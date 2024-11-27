class Employees::SessionsController < Devise::SessionsController
  before_action :authenticate_employee!, except: [:new, :create, :destroy]

  protected

  def after_sign_in_path_for(resource)
    profile_employees_path
  end

  def after_sign_out_path_for(resource_or_scope)
    new_employee_session_path
  end
end
