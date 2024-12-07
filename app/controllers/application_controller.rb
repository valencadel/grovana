class ApplicationController < ActionController::Base
  include Pundit::Authorization
  helper_method :policy, :pundit_policy_scope, :current_company

  allow_browser versions: :modern

  before_action :authenticate_any!
  before_action :configure_permitted_parameters, if: :devise_controller?


  protected
  def current_company
    @current_company ||= if current_user
                           current_user.companies.first
    elsif current_employee
                           current_employee.company
    end
  end

  def authenticate_any!
    unless current_user || current_employee
      authenticate_user!
    end
  end

  def pundit_user
    current_user || current_employee
  end

  def after_sign_in_path_for(resource)
    dashboard_path
  end

  def policy_scope(scope)
    Pundit::PolicyFinder.new(scope).scope!.new(
      pundit_user,
      scope,
      { current_employee: current_employee }
    ).resolve
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :first_name,
      :last_name,
      :phone,
      :role,
      :status
    ])

    devise_parameter_sanitizer.permit(:account_update, keys: [
      :first_name,
      :last_name,
      :phone,
      :role,
      :status
    ])
  end
end
