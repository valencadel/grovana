class Customer < ApplicationRecord
  has_many :sales
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :phone, format: { with: /\A\+?[\d\s-]{8,}\z/ }, allow_blank: true
  validates :first_name, :last_name, presence: true
  validates :tax_id, format: { with: /\A[\dA-Za-z-]+\z/, message: "debe contener solo números, letras o guiones" }, allow_blank: true
end
