class AddRoleAndStatusToEmployees < ActiveRecord::Migration[7.2]
  def change
    add_column :employees, :role, :string
    add_column :employees, :status, :string
  end
end
