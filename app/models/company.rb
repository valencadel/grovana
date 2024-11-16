class Company < ApplicationRecord
  has_many :products
  has_many :employees
  belongs_to :user
  validates :name, presence: true, uniqueness: true
  validates :name, length: { maximum: 100 }
end
