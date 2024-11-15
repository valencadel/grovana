class CreateProducts < ActiveRecord::Migration[7.2]
  def change
    create_table :products do |t|
      t.string :name
      t.string :sku
      t.string :description
      t.string :category
      t.integer :stock
      t.integer :min_stock
      t.string :brand
      t.boolean :status

      t.timestamps
    end
  end
end
