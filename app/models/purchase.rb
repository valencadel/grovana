class Purchase < ApplicationRecord
  belongs_to :supplier
  belongs_to :company
  has_many :purchase_details, dependent: :destroy
  has_many :products, through: :purchase_details

  accepts_nested_attributes_for :purchase_details, 
                              reject_if: :all_blank, 
                              allow_destroy: true

  validates :order_date, presence: true
  validates :total_price, numericality: { greater_than: 0 }
  validate :expected_delivery_date_after_order_date

  private

  def expected_delivery_date_after_order_date
    return unless expected_delivery_date && order_date
    if expected_delivery_date < order_date
      errors.add(:expected_delivery_date, "debe ser posterior a la fecha de pedido")
    end
  end
end
