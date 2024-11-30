class Company < ApplicationRecord
  has_many :customers
  has_many :products
  has_many :employees
  has_many :suppliers
  has_many :purchases
  belongs_to :user
  validates :name, presence: true, uniqueness: true
  validates :name, length: { maximum: 100 }
end
