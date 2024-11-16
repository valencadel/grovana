class RemoveRoleAndStatusFromUsers < ActiveRecord::Migration[7.2]
  def change
    remove_column :users, :role, :string
    remove_column :users, :status, :string
  end
end
