class AddPriceToInvoiceProducts < ActiveRecord::Migration[8.1]
  def change
    add_column :invoice_products, :price, :decimal, precision: 7, scale: 2
    change_column_null :invoice_products, :product_id, true
   end
end
