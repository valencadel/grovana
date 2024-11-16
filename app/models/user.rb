class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :first_name, :last_name, presence: true
  validates :email, presence: true, uniqueness: { scope: :company_id }
  validates :phone, format: { with: /\A\+?[\d\s-]{8,}\z/ }, allow_blank: true
  validates :role, inclusion: { in: %w[admin staff] }, allow_blank: true
  validates :status, inclusion: { in: %w[active inactive] }
end
