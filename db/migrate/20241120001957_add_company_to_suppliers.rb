class AddCompanyToSuppliers < ActiveRecord::Migration[7.2]
  def change
    add_reference :suppliers, :company, null: false, foreign_key: true
  end
end
