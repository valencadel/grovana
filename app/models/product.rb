class Product < ApplicationRecord
  belongs_to :company
  has_many :purchase_details
  has_many :purchases, through: :purchase_details
  has_many :sale_details
  has_many :sales, through: :sale_details

  scope :active, -> { where(status: 'active') }

  validates :name, presence: { message: "no puede estar en blanco" }
  validates :sku, presence: { message: "no puede estar en blanco" },
                 uniqueness: { scope: :company_id, message: "ya existe para esta compañía" }

  validates :min_stock,
            presence: { message: "no puede estar en blanco" },
            numericality: {
              greater_than: 0,
              message: "debe ser mayor que 0",
              allow_blank: false
            }

  validates :stock,
            presence: { message: "no puede estar en blanco" },
            numericality: {
              greater_than: 0,
              message: "debe ser mayor que 0",
              allow_blank: false
            }

  validate :stock_must_not_be_less_than_minimum_stock

  def available_stock
    stock
  end

  def name_with_stock
    "#{name} (Stock: #{stock})"
  end

  private

  def stock_must_not_be_less_than_minimum_stock
    return unless stock && min_stock
    if stock < min_stock
      errors.add(:stock, "no puede ser menor que el stock mínimo")
    end
  end
end
