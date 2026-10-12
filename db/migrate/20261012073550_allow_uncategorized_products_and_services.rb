class AllowUncategorizedProductsAndServices < ActiveRecord::Migration[8.1]
  def change
    # NULL now means "uncategorized": deleting a category nullifies its products/services
    change_column_null :products, :product_category_id, true
    change_column_null :services, :service_category_id, true
  end
end
