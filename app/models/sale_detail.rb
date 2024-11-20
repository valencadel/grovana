class SaleDetail < ApplicationRecord
  belongs_to :sale
  belongs_to :product

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :unit_price, presence: true, numericality: { greater_than: 0 }
  validate :stock_availability

  private

  def stock_availability
    return unless quantity_changed? && product
    if quantity > product.available_stock
      errors.add(:quantity, "Excede el stock disponible (#{product.available_stock} disponible)")
    end
  end
end
