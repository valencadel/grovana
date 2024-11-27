class Product < ApplicationRecord
  belongs_to :company
  has_many :purchase_details
  has_many :purchases, through: :purchase_details
  has_many :sale_details
  has_many :sales, through: :sale_details

  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :stock, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :min_stock, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :active, -> { where(status: true) }

  def available_stock
    stock
  end

  # Método para actualizar el stock después de una venta
  def update_stock_after_sale(quantity)
    update(stock: stock - quantity)
  end
end
