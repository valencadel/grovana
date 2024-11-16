class Company < ApplicationRecord
  has_many :products
  validates :name, presence: true, uniqueness: true
  validates :name, length: { maximum: 100 }
end
