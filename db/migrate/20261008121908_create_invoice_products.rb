class CreateInvoiceProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :invoice_products do |t|
      t.references :invoice, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :quantity
      t.string :description

      t.timestamps
    end
  end
end
