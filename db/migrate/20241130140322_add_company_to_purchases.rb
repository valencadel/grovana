class AddCompanyToPurchases < ActiveRecord::Migration[7.2]
  def change
    add_reference :purchases, :company, null: false, foreign_key: true
  end
end
