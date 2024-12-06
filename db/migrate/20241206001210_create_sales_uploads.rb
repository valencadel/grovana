class CreateSalesUploads < ActiveRecord::Migration[7.2]
  def change
    create_table :sales_uploads do |t|
      t.references :company, null: false, foreign_key: true

      t.timestamps
    end
  end
end
