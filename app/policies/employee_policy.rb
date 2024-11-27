class EmployeePolicy < ApplicationPolicy
  def index?
    user_has_company? || user_is_manager?
  end

  def show?
    user_has_company? || user_is_manager? || is_self?
  end

  def create?
    user_has_company?
  end

  def new?
    create?
  end

  def update?
    user.is_a?(User)
  end

  def edit?
    user.is_a?(User)
  end

  def profile?
    true
  end

  def edit_password?
    true
  end

  def update_password?
    true
  end

  class Scope < Scope
    def resolve
      current_user = user || context[:current_employee]

      Rails.logger.debug "Policy Scope User: #{current_user.inspect}"
      Rails.logger.debug "Policy Scope User Type: #{current_user.class.name}"
      Rails.logger.debug "User role: #{current_user.role}" if current_user.is_a?(Employee)

      if current_user.respond_to?(:companies) && current_user.companies.exists?
        # Si es un usuario (dueño)
        scope.where(company_id: current_user.companies.pluck(:id))
      elsif current_user.is_a?(Employee) && current_user.role == 'Manager'
        # Si es un manager
        scope.where(company_id: current_user.company_id)
      elsif current_user.is_a?(Employee)
        # Si es un empleado regular
        scope.where(id: current_user.id)
      else
        scope.none
      end
    end
  end

  private

  def user_has_company?
    user.present? && (user.respond_to?(:companies) ? user.companies.exists? : user.company.present?)
  end

  def user_is_owner_of_company?
    return false unless user.present? && record.company.present?
    user.respond_to?(:companies) && record.company.user_id == user.id
  end

  def user_is_manager?
    user.is_a?(Employee) && user.role == 'Manager'
  end

  def is_self?
    user.is_a?(Employee) && record.id == user.id
  end
end
