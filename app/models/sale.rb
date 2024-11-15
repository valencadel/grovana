class Sale < ApplicationRecord
  belongs_to :customer
  has_many :sale_details
  has_many :products, through: :sale_details
end
