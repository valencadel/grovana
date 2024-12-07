class Customer < ApplicationRecord
  belongs_to :company
  has_many :sales
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :phone, format: { with: /\A\+?[\d\s-]{8,}\z/ }, allow_blank: true
  validates :first_name, :last_name, presence: true
  validates :tax_id, format: { with: /\A[\dA-Za-z-]+\z/, message: "must contain only numbers, letters or dashes" }, allow_blank: true
  geocoded_by :address
  after_validation :geocode, if: :will_save_change_to_address?

def name
  "#{first_name} #{last_name}"
end
end
