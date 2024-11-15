class Purchase < ApplicationRecord
  belongs_to :supplier
  has_many :purchase_details
  has_many :products, through: :purchase_details
end
