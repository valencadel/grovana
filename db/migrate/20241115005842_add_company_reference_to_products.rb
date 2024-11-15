class AddCompanyReferenceToProducts < ActiveRecord::Migration[7.2]
  def change
    add_reference :products, :company, null: false, foreign_key: true
  end
end
