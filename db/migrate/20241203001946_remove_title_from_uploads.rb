class RemoveTitleFromUploads < ActiveRecord::Migration[7.2]
  def change
    remove_column :uploads, :title, :string
  end
end
