class AddArchivedAtToProductsAndServices < ActiveRecord::Migration[8.1]
  def change
    # nil = in use; a time = archived, and when
    add_column :products, :archived_at, :datetime
    add_column :services, :archived_at, :datetime
  end
end
