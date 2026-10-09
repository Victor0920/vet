class AddColorToProductCategory < ActiveRecord::Migration[8.1]
  def change
    add_column :product_categories, :color, :string
    add_column :service_categories, :color, :string
  end
end
