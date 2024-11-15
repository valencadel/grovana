class Product < ApplicationRecord
  belongs_to :company
  has_many :purchase_details
  has_many :purchases, through: :purchase_details
  has_many :sale_details
  has_many :sales, through: :sale_details
end
