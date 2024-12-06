class Sale < ApplicationRecord
  belongs_to :customer
  has_many :sale_details, dependent: :destroy
  has_many :products, through: :sale_details

  accepts_nested_attributes_for :sale_details,
                              allow_destroy: true,
                              reject_if: :all_blank

  validates :payment_method, presence: true
  validates :sale_date, presence: true
  validates :total_price, numericality: { greater_than: 0 }
  validates :payment_method, inclusion: { in: %w[cash credit_card transfer] }
  validate :sale_date_cannot_be_in_the_future

  private

  def sale_date_cannot_be_in_the_future
    return unless sale_date.present? && sale_date > Date.today
    errors.add(:sale_date, "can't be in the future")
  end
end
