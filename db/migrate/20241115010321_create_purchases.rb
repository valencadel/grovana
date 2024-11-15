class CreatePurchases < ActiveRecord::Migration[7.2]
  def change
    create_table :purchases do |t|
      t.date :order_date
      t.date :expected_delivery_date
      t.integer :total_price

      t.timestamps
    end
  end
end
