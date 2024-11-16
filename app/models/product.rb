class Product < ApplicationRecord
  belongs_to :company
  has_many :purchase_details
  has_many :purchases, through: :purchase_details
  has_many :sale_details
  has_many :sales, through: :sale_details

  validates :name, presence: true
  validates :sku, presence: true, uniqueness: { scope: :company_id }
  validates :minimum_stock, numericality: { greater_than_or_equal_to: 0 }
  validates :stock, numericality: { greater_than_or_equal_to: 0 }
  validates :total_price, :sell_price, numericality: { greater_than: 0 }, allow_nil: true
  validate :stock_must_not_be_less_than_minimum_stock
end

def stock_must_not_be_less_than_minimum_stock
  return unless stock && minimum_stock
  if stock < minimum_stock
    errors.add(:stock, "no puede ser menor que el stock mínimo")
  end
end
