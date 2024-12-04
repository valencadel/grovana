class AddCompanyToUploads < ActiveRecord::Migration[7.2]
  def change
    add_reference :uploads, :company, null: false, foreign_key: true
  end
end
