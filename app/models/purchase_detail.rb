class PurchaseDetail < ApplicationRecord
  belongs_to :purchase
  belongs_to :product

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :unit_price, presence: true, numericality: { greater_than: 0 }

  after_create :update_product_stock

  private

  def update_product_stock
    product.update_stock_after_purchase(quantity)
  end
end
