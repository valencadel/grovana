class ApplicationController < ActionController::Base
  include Pundit::Authorization
  helper_method :policy, :pundit_policy_scope

  allow_browser versions: :modern

  before_action :authenticate_user!

  protected

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
