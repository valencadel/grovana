class AddNameToEmployees < ActiveRecord::Migration[7.2]
  def change
    add_column :employees, :first_name, :string
    add_column :employees, :last_name, :string
  end
end
