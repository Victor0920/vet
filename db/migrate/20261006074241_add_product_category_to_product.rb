class AddProductCategoryToProduct < ActiveRecord::Migration[8.1]
  class MigrationProductCategory < ActiveRecord::Base
    self.table_name = "product_categories"
  end

  class MigrationProduct < ActiveRecord::Base
    self.table_name = "products"
  end

  def up
    # 1. Add the column, nullable for now
    add_reference :products, :product_category, null: true, foreign_key: true

    # 2. Backfill existing products with a default category
    MigrationProduct.reset_column_information
    if MigrationProduct.exists?
      default = MigrationProductCategory.find_or_create_by!(name: "Uncategorized")
      MigrationProduct.where(product_category_id: nil)
                      .update_all(product_category_id: default.id)
    end

    # 3. Now every row has a value, so enforce NOT NULL
    change_column_null :products, :product_category_id, false
  end

  def down
    remove_reference :products, :product_category, foreign_key: true
  end
end
