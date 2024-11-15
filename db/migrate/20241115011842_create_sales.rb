class CreateSales < ActiveRecord::Migration[7.2]
  def change
    create_table :sales do |t|
      t.date :sale_date
      t.string :payment_method
      t.integer :total_price

      t.timestamps
    end
  end
end
