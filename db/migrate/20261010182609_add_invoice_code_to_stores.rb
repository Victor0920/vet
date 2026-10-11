class AddInvoiceCodeToStores < ActiveRecord::Migration[8.1]
  def change
    add_column :stores, :invoice_code, :string
    add_index :stores, [ :enterprise_id, :invoice_code ], unique: true
  end
end
