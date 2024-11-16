class Purchase < ApplicationRecord
  belongs_to :supplier
  has_many :purchase_details
  has_many :products, through: :purchase_details

  validates :order_date, presence: true
  validates :total_price, numericality: { greater_than: 0 }
  validate :expected_delivery_date_after_order_date
end

def expected_delivery_date_after_order_date
  return unless expected_delivery_date && order_date
  if expected_delivery_date < order_date
    errors.add(:expected_delivery_date, "debe ser posterior a la fecha de pedido")
  end
end
