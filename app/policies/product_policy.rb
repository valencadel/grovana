class ProductPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    user.present?
  end

  def create?
    user.present?
  end

  def new?
    create?
  end

  def update?
    user_is_owner_of_company?
  end

  def edit?
    update?
  end

  private

  def user_is_owner_of_company?
    user.present? && record.company&.user_id == user.id
  end
end
