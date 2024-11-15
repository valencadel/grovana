class AddSupplierReferenceToPurchases < ActiveRecord::Migration[7.2]
  def change
    add_reference :purchases, :supplier, null: false, foreign_key: true
  end
end
