class Sale < ApplicationRecord
  belongs_to :customer
  has_many :sale_details, dependent: :destroy
  has_many :products, through: :sale_details

  accepts_nested_attributes_for :sale_details, 
                              reject_if: :all_blank, 
                              allow_destroy: true

  validates :payment_method, presence: true
  validates :sale_date, presence: true
  validates :total_price, numericality: { greater_than: 0 }
  validates :payment_method, inclusion: { in: %w[Efectivo tarjeta_credito transferencia] }
  validate :sale_date_cannot_be_in_the_future

  private

  def sale_date_cannot_be_in_the_future
    return unless sale_date.present? && sale_date > Date.today
    errors.add(:sale_date, "no puede ser en el futuro")
  end
end
