class AddCompanyIdToCustomers < ActiveRecord::Migration[7.2]
  def change
    add_reference :customers, :company, null: true, foreign_key: true
  end
end
