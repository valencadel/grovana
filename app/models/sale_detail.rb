class SaleDetail < ApplicationRecord
  belongs_to :sale
  belongs_to :product

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :unit_price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  validate :stock_availability
  after_create :update_product_stock

  private

  def stock_availability
    return unless quantity_changed? && product
    if quantity > product.stock
      errors.add(:quantity, "Excede el stock disponible (#{product.stock} disponible)")
    end
  end

  def update_product_stock
    product.update_stock_after_sale(quantity)
  end
end
