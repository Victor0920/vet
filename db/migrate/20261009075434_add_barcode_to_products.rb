class AddBarcodeToProducts < ActiveRecord::Migration[8.1]
  def change
    add_column :products, :barcode, :string
  end
end
