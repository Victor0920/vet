class AddVatRateToPrices < ActiveRecord::Migration[8.1]
  # change_column can't be undone automatically (Rails doesn't know the old type), so up/down
  def up
    # Existing products and services get 0 %: their price stays what customers pay until someone edits them
    add_column :products, :vat_rate, :decimal, precision: 5, scale: 2, null: false, default: 0
    add_column :services, :vat_rate, :decimal, precision: 5, scale: 2, null: false, default: 0
    # ...but new ones start at 21 %
    change_column_default :products, :vat_rate, 21
    change_column_default :services, :vat_rate, 21
    # Each invoice line keeps its own copy, like the price, so editing a product never changes an issued invoice
    add_column :invoice_products, :vat_rate, :decimal, precision: 5, scale: 2, null: false, default: 21

    # The price without VAT, with 4 decimals: 10,00 € final at 21 % is 8,2645, which comes back as 10,00
    change_column :products, :price, :decimal, precision: 9, scale: 4
    change_column :services, :price, :decimal, precision: 9, scale: 4
    change_column :invoice_products, :price, :decimal, precision: 9, scale: 4
  end

  def down
    change_column :products, :price, :decimal, precision: 7, scale: 2
    change_column :services, :price, :decimal, precision: 7, scale: 2
    change_column :invoice_products, :price, :decimal, precision: 7, scale: 2
    remove_column :products, :vat_rate
    remove_column :services, :vat_rate
    remove_column :invoice_products, :vat_rate
  end
end
