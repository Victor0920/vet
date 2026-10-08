class AddShowWarningBelowStockToProducts < ActiveRecord::Migration[8.1]
  def change
    add_column :products, :show_warning_when_stock_under_x_items, :integer, default: 5, null: false
  end
end
