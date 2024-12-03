class Company < ApplicationRecord
  belongs_to :user
  has_many :users
  has_many :customers
  has_many :products
  has_many :employees
  has_many :suppliers
  has_many :purchases
  has_many :uploads, dependent: :destroy
  validates :name, presence: true, uniqueness: true
  validates :name, length: { maximum: 100 }
end
