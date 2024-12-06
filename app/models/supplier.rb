class Supplier < ApplicationRecord
  has_many :purchases
  belongs_to :company

  validates :company_name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :tax_id, format: { with: /\A[\dA-Za-z-]+\z/, message: "must contain only numbers, letters or dashes" }, allow_blank: true
  validates :phone, format: { with: /\A\+?[\d\s-]{8,}\z/ }, allow_blank: true
end
