class User < ApplicationRecord
  has_many :companies, foreign_key: 'user_id'
  belongs_to :company, optional: true

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :first_name, :last_name, presence: true
  validates :phone, format: { with: /\A[0-9]+\z/, message: "solo permite números" }, allow_blank: true
end
