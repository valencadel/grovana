class AddCoordinatesToCustomers < ActiveRecord::Migration[7.2]
  def change
    add_column :customers, :latitude, :float
    add_column :customers, :longitude, :float
  end
end
