class CreateSuppliers < ActiveRecord::Migration[7.2]
  def change
    create_table :suppliers do |t|
      t.string :company_name
      t.string :contact_name
      t.string :email
      t.string :phone
      t.string :address
      t.string :tax_id

      t.timestamps
    end
  end
end
