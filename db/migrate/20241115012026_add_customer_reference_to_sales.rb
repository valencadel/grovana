class AddCustomerReferenceToSales < ActiveRecord::Migration[7.2]
  def change
    add_reference :sales, :customer, null: false, foreign_key: true
  end
end
